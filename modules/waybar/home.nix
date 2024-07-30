{ pkgs, ... }: {
  programs.waybar = {
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
          format = "<span font='11'>{name}</span>";
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
          format-wifi = "{ipaddr} <span font='11'></span>";
          format-disconnected = "Disconnected";
          interval = 5;
        };

        "custom/weather" = {
          exec = pkgs.writeShellScript "waybar-weather" (builtins.readFile ../../bin/weather-indicator.sh);
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
          exec = pkgs.writeShellScript "waybar-yubikey" (builtins.readFile ../../bin/yubikey-indicator.sh);
        };

        "custom/spotify" = {
          exec = pkgs.writeShellScript "waybar-spotify" (builtins.readFile ../../bin/spotify-indicator.sh);
          interval = 1;
        };
      };
    };

    style = ./style.css;
  };

  wayland.windowManager.hyprland.settings.exec-once = [
    "${pkgs.waybar}/bin/waybar"
  ];
}
