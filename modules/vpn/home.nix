{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kibadda;

  vpn-names = builtins.concatStringsSep " " (builtins.attrNames cfg.vpn);

  wgctl = pkgs.writeShellApplication {
    name = "wgctl";
    text = ''
      set -euo pipefail

      NAME="''${1:-}"
      ACTION="''${2:-}"

      if [ -z "$NAME" ]; then
        echo "Usage: wgctl <config-name> [up|down]"
        exit 1
      fi

      VALID_NAMES="${vpn-names}"

      if ! echo "$VALID_NAMES" | tr ' ' '\n' | grep -qx "$NAME"; then
        echo "Error: unknown wireguard config '$NAME'"
        exit 1
      fi

      SERVICE="wg-quick-$NAME.service"

      is_active() {
        systemctl is-active --quiet "$SERVICE"
      }

      case "$ACTION" in
        up)
          echo "Starting $NAME"
          sudo systemctl start "$SERVICE"
          ;;
        down)
          echo "Stopping $NAME"
          sudo systemctl stop "$SERVICE"
          ;;
        "")
          if is_active; then
            echo "Stopping $NAME"
            sudo systemctl stop "$SERVICE"
          else
            echo "Starting $NAME"
            sudo systemctl start "$SERVICE"
          fi
          ;;
      esac
    '';
  };
in
{
  options = {
    kibadda.vpn = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

  config = lib.mkIf (cfg.vpn != { }) {
    home.packages = [ wgctl ];
  };
}
