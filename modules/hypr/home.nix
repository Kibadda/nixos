{ lib, pkgs, config, inputs, ... }: with lib; let
  cfg = config.kibadda;

  wallpaper = ".config/hypr/wallpaper.png";
in {
  config = mkIf cfg.hypr.enable {
    home = {
      packages = [
        pkgs.hyprshade
        inputs.powermenu.defaultPackage.${pkgs.system}
        inputs.dmenu.defaultPackage.${pkgs.system}
      ];

      file = {
        ".local/bin/screenshot" = {
          executable = true;
          source = ../../bin/hypr-screenshot.sh;
        };

        ".config/hypr/hyprshade.toml" = {
          text = ''
            [[shades]]
            name = "blue-light-filter"
            start_time = 19:00:00
            end_time = 07:00:00
          '';
        };

        ${wallpaper} = {
          source = cfg.wallpaper;
        };
      };

      pointerCursor = cfg.hypr.cursor;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        input = {
          kb_layout = "de";
          kb_options = "caps:swapescape";
          numlock_by_default = 1;

          touchpad = {
            natural_scroll = true;
            tap-to-click = true;
          };
        };

        general = {
          border_size = 1;
          gaps_in = 5;
          gaps_out = 5;
          layout = "dwindle";
        };

        decoration = {
          rounding = 0;
        };

        animations = {
          enabled = "yes";
          bezier = "custom, 0.1, 0.7, 0.1, 1.05";
          animation = [
            "fade, 1, 7, default"
            "windows, 1, 7, custom"
            "windowsOut, 1, 3, default, popin 60%"
            "windowsMove, 1, 7, custom"
          ];
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
        };

        env = [
          "XDG_SESSION_TYPE,wayland"
          "NIXOS_OZONE_WL,1"
        ] ++ (if cfg.hypr.nvidia then [
          "LIBVA_DRIVER_NAME,nvidia"
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        ] else []);

        monitor = cfg.hypr.monitor;

        cursor = mkIf cfg.hypr.nvidia {
          no_hardware_cursors = true;
        };

        bind = [
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 5"
          "SUPER SHIFT, 1, movetoworkspace, 1"
          "SUPER SHIFT, 2, movetoworkspace, 2"
          "SUPER SHIFT, 3, movetoworkspace, 3"
          "SUPER SHIFT, 4, movetoworkspace, 4"
          "SUPER SHIFT, 5, movetoworkspace, 5"

          "SUPER, Return, exec, kitty"
          "SUPER, B, exec, google-chrome-stable"
          "SUPER SHIFT, B, exec, google-chrome-stable --incognito"
          "SUPER, D, exec, kitty --class kitty-dmenu --config ~/.config/kitty/tool.conf dmenu"
          "SUPER, Escape, exec, kitty --class kitty-powermenu --config ~/.config/kitty/tool.conf powermenu"

          "SUPER, Q, killactive"
          "SUPER, Space, togglefloating"
          "SUPER SHIFT, Space, fullscreen, 0"
          "SUPER, h, movefocus, l"
          "SUPER, j, movefocus, d"
          "SUPER, k, movefocus, u"
          "SUPER, l, movefocus, r"
          "SUPER SHIFT, h, movewindow, l"
          "SUPER SHIFT, j, movewindow, d"
          "SUPER SHIFT, k, movewindow, u"
          "SUPER SHIFT, l, movewindow, r"
          "SUPER, mouse:273, killactive"

          ", XF86AudioLowerVolume, exec, pamixer -d 5"
          ", XF86AudioRaiseVolume, exec, pamixer -i 5"
          ", XF86AudioMute, exec, pamixer -t"
          ", XF86AudioPlay, exec, playerctl -p spotify play-pause"
          ", XF86AudioPrev, exec, playerctl -p spotify previous"
          ", XF86AudioNext, exec, playerctl -p spotify next"
          "SUPER, XF86AudioPlay, exec, playerctl play-pause"
          "SUPER, XF86AudioPrev, exec, playerctl previous"
          "SUPER, XF86AudioNext, exec, playerctl next"
          ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set 10%+"

          ", Print, exec, screenshot area clip"
          "SUPER, Print, exec, screenshot clip"
          "CONTROL, Print, exec, screenshot area"
          "SUPER CONTROL, Print, exec, screenshot"
        ] ++ cfg.hypr.bind;

        bindm = [
          "SUPER, mouse:272, movewindow"
        ];

        windowrulev2 = [
          "float, class:^(kitty-powermenu)$"
          "size 200 220, class:^(kitty-powermenu)$"
          "center, class:^(kitty-powermenu)$"

          "float, class:^(kitty-dmenu)$"
          "size 400 400, class:^(kitty-dmenu)$"
          "center, class:^(kitty-dmenu)$"

          "float, class:^(kitty-pinentry)$"
          "size 300 250, class:^(kitty-pinentry)$"
          "center, class:^(kitty-pinentry)$"
        ] ++ cfg.hypr.windowrule;

        workspace = cfg.hypr.workspace;

        exec-once = [
          "${pkgs.hyprpaper}/bin/hyprpaper"
          "${pkgs.waybar}/bin/waybar"
        ] ++ (optional (cfg.hypr.cursor != null) "hyprctl setcursor \"${cfg.hypr.cursor.name}\" ${toString cfg.hypr.cursor.size}") ;

        exec = [
          "${pkgs.hyprshade}/bin/hyprshade auto"
        ];
      };
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [ "~/${wallpaper}" ];
        wallpaper = [ ",~/${wallpaper}" ];
      };
    };

    programs.waybar = {
      enable = true;

      settings = {
        top = {
          layer = "top";
          position = "top";
          height = 34;

          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "custom/weather" ];
          modules-right = (optional cfg.hypr.waybar.battery "battery")
            ++ (optional cfg.hypr.waybar.backlight "backlight")
            ++ [ "cpu" "memory" "disk" "pulseaudio" "network" ];

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

          battery = {
            format = "{capacity}% <span font='11'>{icon}</span> ";
            format-charging = "{capacity}% <span font='11'></span>";
            format-plugged = "{capacity}% <span font='11'></span>";
            format-icons = [ "" "" "" "" "" ];
            states = {
              critical = 25;
            };
          };

          backlight = {
            device = "intel_backlight";
            format = "{percent}% <span font='11'></span> ";
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

      style = ''
        * {
          font-family: ${cfg.font} Nerd Font;
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
        #backlight {
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
      '';
    };
  };
}
