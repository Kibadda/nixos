{ pkgs, ... }: {
  enable = true;

  settings = {
    top = {
      layer = "top";
      position = "top";
      height = 34;

      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "custom/weather" ];
      modules-right = [ "cpu" "memory" "disk" "pulseaudio" "network" ];

      "hyprland/workspaces" = {
        format = "<span font='11'>{name}</spane>";
      };

      cpu = {
        format = "{usage}% <span font='11'></span>";
        interval = 1;
      };

      memory = {
        format = "{percentage}% <span font='11'></span>";
        interval = 1;
      };

      disk = {
        format = "{percentage_used}% <span font='11'></span>";
      };

      pulseaudio = {
        format = "{volume}% <span font='11'>{icon}</span>";
        format-muted = "{volume}% <span font='11'></span>";
        format-icons = {
          default = [ "" "" "" ];
        };
      };

      network = {
        format-ethernet = "{ipaddr} <span font='11'></span>";
        format-ethernet = "{ipaddr} <span font='11'></span>";
        format-disconnected = "Disconnected";
        interval = 5;
      };

      "custom/weather" = {
        exec = pkgs.writeShellScript "waybar-weather" ''
          for i in {1..5}
          do
            text=$(curl -s "https://wttr.in/Ulm+Germany?format=1")
            if [[ $? == 0 ]];
            then
              text=$(echo "$text" | sed -E "s/\s+/ /g")
              echo "$text"
              exit
            fi
            sleep 2
          done
          echo ""
        '';
        interval = 3600;
      };
    };

    bottom = {
      layer = "top";
      position = "bottom";
      height = 34;

      modules-left = [ "custom/spotify" ];
      modules-center = [ "custom/yubikey" ];
      modules-right = [ "clock" ];

      clock = {
        format = "{:%H:%M:%S - %d.%m.%Y}";
        interval = 1;
      };

      "custom/yubikey" = {
        exec = pkgs.writeShellScript "waybar-yubikey" ''
          socket="$XDG_RUNTIME_DIR/yubikey-touch-detector.socket"

          while true; do
            if [ ! -e "$socket" ]; then
              echo "Waiting for Yubikey socket\n"
              while [ ! -e "$socket" ]; do sleep 1; done
            fi

            echo ""

            nc -U "$socket" | while read -n5 cmd; do
              if [ $(echo $cmd | cut -d'_' -f2) = "1" ]; then
                echo "🔑 Yubikey 🔑"
              else
                echo ""
              fi
            done

            sleep 1
          done
        '';
      };

      "custom/spotify" = {
        exec = pkgs.writeShellScript "waybar-spotify" ''
          if playerctl -p spotify status 1>/dev/null 2>/dev/null; then
            status=""

            if [ $(playerctl -p spotify status) == "Paused" ]; then
              status=""
            fi

            song=$(playerctl -p spotify metadata --format "{{ artist }} - {{ title }}")
            time=$(playerctl -p spotify metadata --format "{{ duration(position) }} / {{ duration(mpris:length) }}")

            echo "  $song  $status  $time"
          else
            echo "  spotify not running"
          fi
        '';
        interval = 1;
      };
    };
  };

  style = ./style.css;
}
