{ config, pkgs, lib, ... }: let
  cfg = config.kibadda;
in {
  options = {
    kibadda.hypr.waybar = {
      battery = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      backlight = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.hypr.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${pkgs.waybar}/bin/waybar"
    ];

    programs.waybar = {
      enable = true;

      settings = {
        top = {
          layer = "top";
          position = "top";
          height = 34;

          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "custom/weather" ];
          modules-right = (lib.optional cfg.hypr.waybar.battery "battery")
            ++ (lib.optional cfg.hypr.waybar.backlight "backlight")
            ++ [ "bluetooth" "cpu" "memory" "disk" "pulseaudio" "network" ];

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
              default = [ " " " " " " ];
            };
          };

          network = {
            format-ethernet = "<span font='11'></span> {ipaddr}";
            format-wifi = "<span font='11'> </span> {ipaddr}";
            format-disconnected = "Disconnected";
            interval = 5;
          };

          "custom/weather" = {
            exec = pkgs.kibadda.weather-indicator;
            interval = 3600;
          };

          battery = {
            format = "<span font='11'>{icon}</span> {capacity}%";
            format-charging = "<span font='11'></span> {capacity}%";
            format-plugged = "<span font='11'></span> {capacity}%";
            format-icons = [ "" "" "" "" "" ];
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
            exec = pkgs.kibadda.yubikey-indicator;
          };

          "custom/spotify" = {
            exec = pkgs.kibadda.spotify-indicator;
            interval = 1;
          };
        };
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
      '';
    };
  };
}
