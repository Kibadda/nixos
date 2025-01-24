{ inputs, ... }:
{
  additions = final: prev: {
    kibadda = {
      dmenu = inputs.dmenu.defaultPackage.${prev.system};
      powermenu = inputs.powermenu.defaultPackage.${prev.system};
      passmenu = inputs.passmenu.defaultPackage.${prev.system};
      nvim = inputs.nvim.packages.${prev.system}.nvim;

      spotify-indicator = final.writeShellApplication {
        name = "spotify-indicator";
        runtimeInputs = [
          final.playerctl
          final.toybox
        ];
        text = ''
          if playerctl -p spotify status 1>/dev/null 2>/dev/null; then
            status=""

            if [ "$(playerctl -p spotify status)" == "Paused" ]; then
              status=""
            fi

            song=$(playerctl -p spotify metadata --format "{{ artist }} - {{ title }}")
            time=$(playerctl -p spotify metadata --format "{{ duration(position) }} / {{ duration(mpris:length) }}")

            echo "  $song  $status  $time"
          else
            echo "  spotify not running"
          fi
        '';
      };

      yubikey-indicator = final.writeShellApplication {
        name = "yubikey-indicator";
        runtimeInputs = [ final.toybox ];
        text = ''
          socket="$XDG_RUNTIME_DIR/yubikey-touch-detector.socket"

          while true; do
            if [ ! -e "$socket" ]; then
              echo "Waiting for Yubikey socket"
              while [ ! -e "$socket" ]; do sleep 1; done
            fi

            echo ""

            nc -U "$socket" | while read -r -n5 cmd; do
              if [ "$(echo "$cmd" | cut -d'_' -f2)" = "1" ]; then
                echo "🔑 Yubikey 🔑"
              else
                echo ""
              fi
            done

            sleep 1
          done
        '';
      };

      weather-indicator = final.writeShellApplication {
        name = "weather-indicator";
        runtimeInputs = [
          final.curl
          final.toybox
        ];
        text = ''
          for _ in {1..5}
          do
            if ! text=$(curl -s "https://wttr.in/Ulm+Germany?format=1");
            then
              text=$(echo "$text" | sed -E "s/\s+/ /g")
              echo "$text"
              exit
            fi
            sleep 2
          done
          echo ""
        '';
      };

      screenshot = final.writeShellApplication {
        name = "screenshot";
        runtimeInputs = [
          final.grim
          final.slurp
          final.wl-clipboard
        ];
        text = ''
          clip=0
          area=0

          for arg in "$@"
          do
            case $arg in
              clip) clip=1 ;;
              area) area=1 ;;
            esac
          done

          if [ $clip -eq 1 ]; then
            if [ $area -eq 1 ]; then
              grim -g "$(slurp)" - | wl-copy
            else
              grim - | wl-copy
            fi
          else
            dir="$HOME/Pictures"
            [[ -d "$dir" ]] || mkdir "$dir"

            filename="$dir/$(date +'%Y-%m-%d_%H:%M:%S_grim.png')"

            if [ $area -eq 1 ]; then
              grim -g "$(slurp)" "$filename"
            else
              grim "$filename"
            fi
          fi
        '';
      };
    };
  };

  modifications = final: prev: { };

  unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
