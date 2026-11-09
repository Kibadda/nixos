{
  inputs,
  secrets,
  ...
}:
let
  lib = inputs.nixpkgs.lib;

  installer = lib.nixosSystem {
    modules = [
      "${inputs.nixpkgs.outPath}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

      { nixpkgs.hostPlatform = "x86_64-linux"; }

      (
        { pkgs, ... }:
        let
          installHost = pkgs.writeShellApplication {
            name = "install-host";
            runtimeInputs = with pkgs; [
              coreutils
              disko
              git
              git-crypt
              nix
            ];
            text = ''
              set -euo pipefail

              usage() {
                cat <<'EOF'
              Usage: install-host [--yes] <host> [repo-dir]

                host       NixOS configuration name from the flake
                repo-dir   checkout of the NixOS flake (default: ~/nixos)

              Environment:
                NIXOS_REPO  git URL to clone into repo-dir if it does not exist
              EOF
              }

              yes=0
              if [ "''${1:-}" = "--yes" ]; then
                yes=1
                shift
              fi

              host="''${1:-}"
              repo="''${2:-$HOME/nixos}"

              if [ -z "$host" ]; then
                usage
                exit 2
              fi

              if [ ! -d "$repo" ]; then
                if [ -n "''${NIXOS_REPO:-}" ]; then
                  git clone "$NIXOS_REPO" "$repo"
                else
                  echo "error: $repo does not exist" >&2
                  echo "hint: git clone <repo> $repo, or set NIXOS_REPO=<url>" >&2
                  exit 1
                fi
              fi

              cd "$repo"

              if [ ! -e flake.nix ]; then
                echo "error: $repo is not a flake checkout" >&2
                exit 1
              fi

              if [ -n "$(git status --porcelain 2>/dev/null || true)" ]; then
                echo "warning: working tree has uncommitted changes" >&2
              fi

              # Evaluate before touching any disk. This also proves the
              # git-crypt secrets are unlocked.
              if ! nix eval --raw ".#nixosConfigurations.$host.config.system.build.toplevel.drvPath" >/dev/null; then
                echo "error: cannot evaluate .#nixosConfigurations.$host" >&2
                echo "hint: run 'git-crypt unlock /path/to/key' in $repo" >&2
                exit 1
              fi

              if [ "$yes" -ne 1 ]; then
                echo
                echo "About to DESTROY and install host '$host'."
                echo "Repo: $repo"
                printf "Type the host name to continue: "
                read -r confirm || exit 1
                if [ "$confirm" != "$host" ]; then
                  echo "aborted" >&2
                  exit 1
                fi
              fi

              sudo disko --mode destroy,format,mount --flake ".#$host"
              sudo nixos-install --flake ".#$host" --no-root-password

              echo
              echo "Installed '$host'. Reboot when ready: reboot"
            '';
          };
        in
        {
          networking.hostName = "installer";
          time.timeZone = "Europe/Berlin";
          console.keyMap = "de";

          isoImage = {
            volumeID = "nixos-installer";
            edition = "minimal";
          };

          users.motd = ''
            NixOS live installer

              1. nmtui                              configure network
              2. git clone <repo> ~/nixos           get the flake
              3. git-crypt unlock /path/to/key      unlock secrets
              4. install-host <host>                disko + nixos-install

            install-host wipes the target disk. Read it before running.
          '';

          environment.systemPackages = [
            installHost
          ]
          ++ (with pkgs; [
            btrfs-progs
            cryptsetup
            disko
            dosfstools
            e2fsprogs
            file
            git-crypt
            gnupg
            gptfdisk
            htop
            openssh
            parted
            pciutils
            rsync
            tmux
            usbutils
            util-linux
            vim
          ]);

          # Public keys only. Never bake private keys into an ISO.
          users.users.root.openssh.authorizedKeys.keys = secrets.base.sshAuthorizedKeys;
          users.users.nixos.openssh.authorizedKeys.keys = secrets.base.sshAuthorizedKeys;

          services.openssh.settings = {
            PermitRootLogin = "prohibit-password";
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
          };

          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
        }
      )
    ];
  };
in
{
  perSystem =
    { system, ... }:
    {
      packages = lib.optionalAttrs (system == "x86_64-linux") {
        installer-iso = installer.config.system.build.isoImage;
      };
    };
}
