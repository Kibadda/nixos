{
  lib,
  ...
}:
{
  flake.homeModules.config-checker =
    {
      config,
      pkgs,
      ...
    }:
    {
      options.kibadda.config-directory = lib.mkOption {
        type = lib.types.str;
        default = "Projects/nixos";
      };

      config = {
        systemd.user = {
          services.fetch-config = {
            Service = {
              Type = "oneshot";
              WorkingDirectory = "%h/${config.kibadda.config-directory}";
              ExecStart = "${pkgs.git}/bin/git fetch";
            };
          };
          timers.fetch-config = {
            Install.WantedBy = [ "timers.target" ];
            Timer = {
              OnCalendar = "*-*-* *:0/10:0";
              Unit = "fetch-config.service";
            };
          };
        };

        programs.zsh.initContent = # bash
          ''
            CONFIG_LOCATION="$HOME/${config.kibadda.config-directory}"

            RED="\033[0;31m"
            BLUE="\033[0;34m"
            NC="\033[0m"

            if [ -z "$CONFIG_LOCATION" ]; then
              echo -e "$RED Error:$NC CONFIG_LOCATION not set."
              exit
            fi

            if [ ! -d "$CONFIG_LOCATION/.git" ]; then
              echo -e "$RED Error:$NC CONFIG_LOCATION is not a git directory."
              exit
            fi

            if [ -n "$(git -C "$CONFIG_LOCATION" status --porcelain)" ]; then
              echo "THERE ARE$RED UNCOMMITED$NC CHANGES IN LOCAL NIX CONFIGURATION!"
            fi

            REMOTE_STATUS="$(git -C "$CONFIG_LOCATION" status -sb | grep -E '\[.*\]')"

            if [[ $REMOTE_STATUS =~ ahead ]]; then
              echo "THE LOCAL NIX CONFIGURATION IS$RED AHEAD$NC OF REMOTE!"
            fi

            if [[ $REMOTE_STATUS =~ behind ]]; then
              echo "The local nix configuration is$BLUE behind$NC remote."
            fi

            if [[ $REMOTE_STATUS =~ diverged ]]; then
              echo "THE LOCAL NIX CONFIGURATION HAS$RED DIVERGED$NC FROM REMOTE!"
            fi
          '';
      };
    };
}
