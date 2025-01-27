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

      home = final.writeShellApplication {
        name = "home";
        text = ''
          if [ "$1" == "up" ]; then
            sudo systemctl start wg-quick-home.service
          elif [ "$1" == "down" ]; then
            sudo systemctl stop wg-quick-home.service
          fi
        '';
      };

      work = final.writeShellApplication {
        name = "work";
        runtimeInputs = [ final.sshfs ];
        text = ''
          work_vpn() {
            if [ "$1" == "up" ]; then
              sudo systemctl start wg-quick-work.service
            elif [ "$1" == "down" ]; then
              sudo systemctl stop wg-quick-work.service
            fi
          }

          work_sshfs() {
            if [ "$1" == "up" ]; then
              sshfs -o Ciphers=aes256-ctr,compression=no,auto_cache,reconnect,uid=1000,gid=1000 work-studies:/opt/studiesbeta /mnt/studiesbeta
            elif [ "$1" == "down" ]; then
              fusermount3 -u /mnt/studiesbeta
            fi
          }

          if [ "$1" == "up" ]; then
            work_vpn up
            work_sshfs up
          elif [ "$1" == "down" ]; then
            work_sshfs down
            work_vpn down
          elif [ "$1" == "vpn" ]; then
            work_vpn "$2"
          elif [ "$1" == "sshfs" ]; then
            work_sshfs "$2"
          fi
        '';
      };

      setup-git-repos = final.writeShellApplication {
        name = "setup-git-repos";
        text = ''
          function check_and_clone() {
            echo "checking $1"
            if [[ ! -d "$1" ]]; then
              echo "-> creating"
              mkdir -p "$1"
              git clone "git@github.com:Kibadda/$2" "$1" -q
            else
              echo "-> skipping"
            fi
          }

          check_and_clone "$PASSWORD_STORE_DIR" "password-store"
          check_and_clone "$NIXVIM_DIR" "nixvim"
          check_and_clone "$NEOVIM_DIR" "neovim"
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
