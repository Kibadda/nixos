{ lib, pkgs, config, ... }: let
  cfg = config.kibadda;
in {
  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hyprshade.nix
    ./waybar.nix
  ];

  options = {
    kibadda.hypr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      nvidia = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      monitor = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      bind = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      windowrule = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      workspace = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      wallpaper = lib.mkOption {
        type = lib.types.path;
        default = ../../wallpapers/forest.png;
      };
    };
  };

  config = lib.mkIf cfg.hypr.enable {
    home = {
      packages = [
        pkgs.kibadda.powermenu
        pkgs.kibadda.dmenu
        # password-store also provides a passmenu binary
        (lib.hiPrio pkgs.kibadda.passmenu)

        pkgs.wl-clipboard
      ];

      file.".config/hypr/wallpaper.png".source = cfg.hypr.wallpaper;
    };

    gtk.enable = true;

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
            disable_while_typing = true;
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

        cursor = lib.mkIf cfg.hypr.nvidia {
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
          "SUPER, P, exec, kitty --class kitty-passmenu --config ~/.config/kitty/tool.conf passmenu"
          "SUPER, Minus, togglespecialworkspace"

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
          # XF86AudioMicMute
          ", XF86AudioMute, exec, pamixer -t"
          ", XF86AudioPlay, exec, playerctl -p spotify play-pause"
          ", XF86AudioPause, exec, playerctl -p spotify play-pause"
          ", XF86AudioPrev, exec, playerctl -p spotify previous"
          ", XF86AudioNext, exec, playerctl -p spotify next"
          "SUPER, XF86AudioPlay, exec, playerctl play-pause"
          "SUPER, XF86AudioPrev, exec, playerctl previous"
          "SUPER, XF86AudioNext, exec, playerctl next"
          ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set 10%+"

          ", Print, exec, ${lib.getExe pkgs.kibadda.screenshot} area clip"
          "SUPER, Print, exec, ${lib.getExe pkgs.kibadda.screenshot} clip"
          "CONTROL, Print, exec, ${lib.getExe pkgs.kibadda.screenshot} area"
          "SUPER CONTROL, Print, exec, ${lib.getExe pkgs.kibadda.screenshot}"
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

          "float, class:^(kitty-passmenu)$"
          "size 400 400, class:^(kitty-passmenu)$"
          "center, class:^(kitty-passmenu)$"

          "float, class:^(kitty-pinentry)$"
          "size 300 250, class:^(kitty-pinentry)$"
          "center, class:^(kitty-pinentry)$"

          "workspace special silent, initialTitle:^(Spotify Premium)$"
        ] ++ cfg.hypr.windowrule;

        workspace = cfg.hypr.workspace;
      };
    };
  };
}
