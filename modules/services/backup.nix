{
  lib,
  secrets,
  ...
}:
{
  flake.nixosModules.backup =
    {
      config,
      pkgs,
      ...
    }:
    let
      services = lib.filterAttrs (
        _: service: service.backup.sync != [ ] || service.backup.archive != [ ]
      ) config.kibadda.services;

      calls = lib.concatStringsSep "\n" (
        lib.flatten (
          lib.mapAttrsToList (
            name: service:
            lib.optional (service.backup.archive != [ ])
              ''backup_archive ${name} ${lib.escapeShellArgs service.backup.archive} || { echo "archive backup of ${name} failed" >&2; failed=1; }''
            ++
              lib.optional (service.backup.sync != [ ])
                ''backup_sync ${name} ${lib.escapeShellArgs service.backup.sync} || { echo "sync backup of ${name} failed" >&2; failed=1; }''
          ) services
        )
      );

      backup = pkgs.writeShellApplication {
        name = "kibadda-backup";
        runtimeInputs = with pkgs; [
          coreutils
          gnutar
          gzip
          gnupg
          awscli2
        ];
        text = ''
          timestamp="$(date +%Y-%m-%dT%H-%M-%S)"
          workdir="$(mktemp -d)"
          trap 'rm -rf "$workdir"' EXIT
          failed=0

          # Print (null-delimited) only the paths that exist, warning about the rest.
          existing_paths() {
            local p
            for p in "$@"; do
              if [ -e "$p" ]; then
                printf '%s\0' "$p"
              else
                echo "skipping missing path: $p" >&2
              fi
            done
          }

          # Archive the given paths into a single tarball, symmetrically encrypt it
          # with the shared passphrase and upload it to the S3 Deep Archive bucket.
          backup_archive() {
            local name="$1"
            shift

            local paths=()
            while IFS= read -r -d "" p; do paths+=("$p"); done < <(existing_paths "$@")
            if [ "''${#paths[@]}" -eq 0 ]; then
              echo "no existing paths for $name, skipping archive" >&2
              return 0
            fi

            local archive="$workdir/$name$timestamp.tar.gz"

            echo "Archiving $name..."
            tar czf "$archive" "''${paths[@]}"

            gpg --batch --yes --pinentry-mode loopback \
              --passphrase-file /etc/backup/passphrase \
              --symmetric --cipher-algo AES256 \
              --output "$archive.gpg" \
              "$archive"

            aws s3 cp "$archive.gpg" \
              "s3://${secrets.pi.backup.bucket}/$name/$name-$timestamp.tar.gz.gpg" \
              --storage-class DEEP_ARCHIVE

            rm -f "$archive" "$archive.gpg"
            echo "Archive of $name complete"
          }

          # Incrementally mirror each path to the S3 Deep Archive bucket. Files are
          # stored as-is (no client-side encryption) under a stable prefix, so only
          # new or changed files are uploaded on subsequent runs.
          backup_sync() {
            local name="$1"
            shift

            local p base
            for p in "$@"; do
              if [ ! -e "$p" ]; then
                echo "skipping missing path: $p" >&2
                continue
              fi
              base="$(basename "$p")"
              echo "Syncing $name/$base..."
              aws s3 sync "$p" "s3://${secrets.pi.backup.bucket}/$name/sync/$base/" \
                --delete \
                --storage-class DEEP_ARCHIVE
            done
          }

          ${calls}

          exit "$failed"
        '';
      };

      download = pkgs.writeShellApplication {
        name = "backup-download";
        runtimeInputs = with pkgs; [
          coreutils
          awscli2
          fzf
        ];
        text = ''
          if [ "$#" -lt 1 ]; then
            echo "usage: backup-download <service> [output-file]" >&2
            exit 1
          fi

          # Reuse the backup service's AWS credentials when available.
          if [ -r /etc/backup/env ]; then
            set -a
            # shellcheck disable=SC1091
            . /etc/backup/env
            set +a
          fi

          name="$1"
          bucket="${secrets.pi.backup.bucket}"

          # List every archive for the service, newest first.
          mapfile -t keys < <(aws s3api list-objects-v2 --bucket "$bucket" --prefix "$name/" \
            --query 'reverse(sort_by(Contents, &LastModified))[].Key' --output text | tr '\t' '\n')

          if [ "''${#keys[@]}" -eq 0 ] || [ -z "''${keys[0]}" ]; then
            echo "no backups found for $name" >&2
            exit 1
          fi

          # Let the user pick the exact archive, so the choice stays stable even
          # if a new backup is created while waiting for a restore to finish.
          key="$(printf '%s\n' "''${keys[@]}" | fzf --prompt="Select backup for $name: ")"

          if [ -z "$key" ]; then
            echo "no backup selected" >&2
            exit 1
          fi

          echo "Selected: $key"

          storage="$(aws s3api head-object --bucket "$bucket" --key "$key" \
            --query 'StorageClass' --output text)"
          restore="$(aws s3api head-object --bucket "$bucket" --key "$key" \
            --query 'Restore' --output text)"

          if [ "$storage" = "DEEP_ARCHIVE" ] || [ "$storage" = "GLACIER" ]; then
            case "$restore" in
              *'ongoing-request="false"'*)
                : # a restored copy is available, fall through to download
                ;;
              *'ongoing-request="true"'*)
                echo "Restore already in progress, try again later." >&2
                exit 0
                ;;
              *)
                echo "Object is in $storage and must be restored before download." >&2
                echo "Requesting restore (Standard tier, available for 2 days)..." >&2
                aws s3api restore-object --bucket "$bucket" --key "$key" \
                  --restore-request '{"Days":2,"GlacierJobParameters":{"Tier":"Standard"}}'
                echo "Restore requested. Deep Archive restores can take up to 12 hours." >&2
                echo "Re-run this command and select the same backup once it has completed." >&2
                exit 0
                ;;
            esac
          fi

          output="''${2:-$(basename "$key")}"
          echo "Downloading to $output..."
          aws s3 cp "s3://$bucket/$key" "$output"
          echo "Done."
        '';
      };

      decrypt = pkgs.writeShellApplication {
        name = "backup-decrypt";
        runtimeInputs = with pkgs; [
          gnupg
        ];
        text = ''
          gpg --batch --pinentry-mode loopback \
            --passphrase-file /etc/backup/passphrase \
            --output "''${1%.gpg}" \
            --decrypt "$1"
        '';
      };
    in
    {
      systemd = {
        services.backup = {
          description = "Backup service data to S3 Deep Archive";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            EnvironmentFile = "/etc/backup/env";
            ExecStart = lib.getExe backup;
          };
        };

        timers.backup = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "03:11";
            Persistent = true;
          };
        };
      };

      environment = {
        etc = {
          "backup/env".text = secrets.pi.backup.environment;
          "backup/passphrase".text = secrets.pi.backup.passphrase;
        };

        systemPackages = [
          decrypt
          download
        ];
      };
    };
}
