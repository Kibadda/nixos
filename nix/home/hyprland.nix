{ pkgs, ... }: {
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

    monitor = [
      "eDP-1, 1920x1080@60, 0x0, 1"
    ];

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
      # "SUPER, D, exec, kitty --class kitty-dmenu --config ~/.config/kitty/tool.conf dmenu"
      # "SUPER, Escape, exec, kitty --class kitty-powermenu --config ~/.config/kitty/tool.conf powermenu"

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

      ", Print, exec, screenshot area clip"
      "SUPER, Print, exec, screenshot clip"
      "CONTROL, Print, exec, screenshot area"
      "SUPER CONTROL, Print, exec, screenshot"
    ];

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
    ];

    exec-once = [
      "${pkgs.waybar}/bin/waybar"
    ];
  };
}
