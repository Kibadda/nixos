{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.kibadda;

  modules = [
    "hyprland/workspaces"
    "bluetooth"
    "backlight"
    "battery"
    "cpu"
    "memory"
    "disk"
    "pulseaudio"
    "network"
    "clock"
    "custom/weather"
    "custom/spotify"
    "custom/yubikey"
  ];
in
{
  options = {
    kibadda.hypr.waybar = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      top = {
        modules-left = lib.mkOption {
          type = lib.types.listOf (lib.types.enum modules);
          default = [ ];
        };

        modules-center = lib.mkOption {
          type = lib.types.listOf (lib.types.enum modules);
          default = [ ];
        };

        modules-right = lib.mkOption {
          type = lib.types.listOf (lib.types.enum modules);
          default = [ ];
        };
      };

      bottom = {
        modules-left = lib.mkOption {
          type = lib.types.listOf (lib.types.enum modules);
          default = [ ];
        };

        modules-center = lib.mkOption {
          type = lib.types.listOf (lib.types.enum modules);
          default = [ ];
        };

        modules-right = lib.mkOption {
          type = lib.types.listOf (lib.types.enum modules);
          default = [ ];
        };
      };

      height = lib.mkOption {
        type = lib.types.int;
        default = 34;
      };

      extraCss = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };

  config = lib.mkIf (cfg.hypr.enable && cfg.hypr.waybar.enable) {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${pkgs.waybar}/bin/waybar"
    ];

    home.packages = [
      pkgs.kibadda.weather-indicator
      pkgs.kibadda.spotify-indicator
      pkgs.kibadda.yubikey-indicator
    ];

    programs.waybar = {
      enable = true;

      settings =
        let
          mkBar = position: {
            layer = "top";
            inherit position;
            height = cfg.hypr.waybar.height;

            modules-left = cfg.hypr.waybar.${position}.modules-left;
            modules-center = cfg.hypr.waybar.${position}.modules-center;
            modules-right = cfg.hypr.waybar.${position}.modules-right;

            "hyprland/workspaces" = {
              format = "<span font='11'>{name}</span>";
            };

            cpu = {
              format = "<span font='11'></span> {usage}%";
              interval = 1;
            };

            memory = {
              format = "<span font='11'></span> {percentage}%";
              interval = 1;
            };

            disk = {
              format = "<span font='11'></span> {percentage_used}%";
            };

            pulseaudio = {
              format = "<span font='11'>{icon}</span> {volume}%";
              format-muted = "<span font='11'>x</span> {volume}%";
              format-icons = {
                default = [
                  " "
                  " "
                  " "
                ];
              };
            };

            network = {
              format-ethernet = "<span font='11'></span> {ipaddr}";
              format-wifi = "<span font='11'> </span> {ipaddr}";
              format-disconnected = "Disconnected";
              interval = 5;
            };

            "custom/weather" = {
              exec = "${pkgs.kibadda.weather-indicator}/bin/weather-indicator";
              interval = 3600;
            };

            battery = {
              format = "<span font='11'>{icon}</span> {capacity}%";
              format-charging = "<span font='11'></span> {capacity}%";
              format-plugged = "<span font='11'></span> {capacity}%";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
              ];
              states = {
                critical = 25;
              };
            };

            backlight = {
              device = "intel_backlight";
              format = "<span font='11'></span> {percent}%";
            };

            bluetooth = {
              format = " {status}";
              format-connected = " {device_alias}";
              format-connected-battery = " {device_alias} {device_battery_percentage}%";
            };

            clock = {
              format = "{:%H:%M:%S - %d.%m.%Y}";
              interval = 1;
            };

            "custom/yubikey" = {
              exec = "${pkgs.kibadda.yubikey-indicator}/bin/yubikey-indicator";
            };

            "custom/spotify" = {
              exec = "${pkgs.kibadda.spotify-indicator}/bin/spotify-indicator";
              interval = 1;
            };
          };
        in
        {
          top = mkBar "top";
          bottom = mkBar "bottom";
        };

      style = ''
        * {
          font-family: ${cfg.font.main.name} Nerd Font;
          font-weight: bold;
        }

        window#waybar {
          background-color: rgba(43, 48, 59, 0.5);
          color: #FFFFFF;
        }

        #workspaces {
          background-color: #34C3A0;
        }

        #workspaces button {
          border-radius: 0;
        }

        #workspaces button.active {
          background-color: #343434;
          color: #34C3A0;
        }

        #clock,
        #custom-yubikey,
        #custom-spotify,
        #cpu,
        #memory,
        #disk,
        #pulseaudio,
        #network,
        #battery,
        #backlight,
        #bluetooth {
          padding: 0 10px;
        }

        #clock {
          background-color: #64727D;
        }

        #custom-yubikey {
          background-color: #FFFF00;
          color: #000000;
        }

        #custom-spotify {
          background-color: #1DB954;
        }

        #cpu,
        #memory,
        #disk {
          background-color: #9B59B6;
        }

        #backlight {
          background-color: #ABFC13;
        }

        #pulseaudio {
          background-color: #2980B9;
        }

        #network {
          background-color: #90B1B1;
        }

        #battery {
          background-color: #2ECC71;
        }
        #battery.charging, #battery.plugged {
          background-color: #2980B9;
        }
        #battery.critical:not(.charging) {
          background-color: #F53C3C;
        }

        #bluetooth {
          background-color: #2980B9;
        }

        ${cfg.hypr.waybar.extraCss}
      '';
    };
  };
}
