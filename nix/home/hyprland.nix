{ pkgs, ... }: {
  enable = true;
  settings = {
    "$mod" = "SUPER";

    extraConfig = ''
      monitor = DP-2, 3840x2160@60, 0x0, 1.5
      monitor = DP-1, 2560x1440@60, 2560x0, 1

      env = XCURSOR_SIZE, 24
      env = LIBVA_DRIVER_NAME, nvidia
      env = XDG_SESSION_TYPE, wayland
      env = GBM_BACKEND, nvidia-drm
      env = __GLX_VENDOR_LIBRARY_NAME, nvidia
      env = WLR_NO_HARDWARE_CURSORS, 1

      input {
        kb_layout = de
        kb_options = caps:swapescape
        numlock_by_default = 1
      }

      general {
        border_size = 1
        gaps_in = 5
        gaps_out = 5
        layout = dwindle
      }

      decoration {
        rounding = 0
      }

      animations {
        enabled = yes
        bezier = custom, 0.1, 0.7, 0.1, 1.05
        animation = fade, 1, 7, default
        animation = windows, 1, 7, custom
        animation = windowsOut, 1, 3, default, popin 60%
        animation = windowsMove, 1, 7, custom
      }

      misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
      }

      # WORKSPACES
      $coding = name:Coding
      $games = name:Games
      $tools = name:Tools

      workspace = $coding, monitor:DP-1, default:true
      workspace = $games, monitor:DP-1
      workspace = $tools, monitor:DP-1

      bind = SUPER, C, workspace, $coding
      bind = SUPER, G, workspace, $games
      bind = SUPER, T, workspace, $tools
      bind = SUPERSHIFT, C, movetoworkspace, $coding

      workspace = 1, monitor:DP-2
      workspace = 2, monitor:DP-2
      workspace = 3, monitor:DP-2
      workspace = 4, monitor:DP-2
      workspace = 5, monitor:DP-2

      bind = SUPER, 1, workspace, 1
      bind = SUPER, 2, workspace, 2
      bind = SUPER, 3, workspace, 3
      bind = SUPER, 4, workspace, 4
      bind = SUPER, 5, workspace, 5
      bind = SUPERSHIFT, 1, movetoworkspace, 1
      bind = SUPERSHIFT, 2, movetoworkspace, 2
      bind = SUPERSHIFT, 3, movetoworkspace, 3
      bind = SUPERSHIFT, 4, movetoworkspace, 4
      bind = SUPERSHIFT, 5, movetoworkspace, 5

      # WINDOW RULES

      # Workspaces
      windowrulev2 = workspace $coding, class:^(kitty)$
      windowrulev2 = workspace $tools, class:^(Spotify)$
      windowrulev2 = workspace $tools, class:^(org.telegram.desktop)$
      windowrulev2 = workspace $tools, class:^(discord)$
      windowrulev2 = workspace $tools, class:^(lutris)$
      windowrulev2 = workspace $tools, class:^(steam)$
      windowrulev2 = workspace $games, class:^(steam.+)$

      windowrulev2 = workspace $games, class:^(Last Epoch.x86_64)$
      windowrulev2 = fullscreen, class:^(Last Epoch.x86_64)$

      windowrulev2 = float, class:^(kitty-powermenu)$
      windowrulev2 = size 200 220, class:^(kitty-powermenu)$
      windowrulev2 = center, class:^(kitty-powermenu)$

      windowrulev2 = float, class:^(kitty-dmenu)$
      windowrulev2 = size 400 400, class:^(kitty-dmenu)$
      windowrulev2 = center, class:^(kitty-dmenu)$

      windowrulev2 = float, class:^(kitty-pinentry)$
      windowrulev2 = size 300 250, class:^(kitty-pinentry)$
      windowrulev2 = center, class:^(kitty-pinentry)$

      windowrulev2 = stayfocused, title:^()$, class:^(steam)$
      windowrulev2 = minsize 1 1, title:^()$, class:^(steam)$

      windowrulev2 = tile, class:^(path of building.exe)$

      # KEYBINDINGS
      bind = SUPER, Return, exec, kitty
      bind = SUPER, B, exec, google-chrome-stable
      bind = SUPERSHIFT, B, exec, google-chrome-stable --incognito
      bind = SUPER, D, exec, kitty --class kitty-dmenu --config ~/.config/kitty/tool.conf dmenu
      bind = SUPER, Escape, exec, kitty --class kitty-powermenu --config ~/.config/kitty/tool.conf powermenu

      # Window Management
      bind = SUPERSHIFT, Q, killactive
      bind = SUPER, Space, togglefloating
      bind = SUPERSHIFT, Space, fullscreen, 0
      bind = SUPER, h, movefocus, l
      bind = SUPER, j, movefocus, d
      bind = SUPER, k, movefocus, u
      bind = SUPER, l, movefocus, r
      bind = SUPERSHIFT, h, movewindow, l
      bind = SUPERSHIFT, j, movewindow, d
      bind = SUPERSHIFT, k, movewindow, u
      bind = SUPERSHIFT, l, movewindow, r
      bindm = SUPER, mouse:272, movewindow
      bind = SUPER, mouse:273, killactive

      # Sound
      bind = , XF86AudioLowerVolume, exec, pamixer -d 5
      bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
      bind = , XF86AudioMute, exec, pamixer -t
      bind = , XF86AudioPlay, exec, playerctl -p spotify play-pause
      bind = , XF86AudioPrev, exec, playerctl -p spotify previous
      bind = , XF86AudioNext, exec, playerctl -p spotify next
      bind = SUPER, XF86AudioPlay, exec, playerctl play-pause
      bind = SUPER, XF86AudioPrev, exec, playerctl previous
      bind = SUPER, XF86AudioNext, exec, playerctl next

      # Screenshot
      bind = , Print, exec, screenshot area clip
      bind = SUPER, Print, exec, screenshot clip
      bind = CONTROL, Print, exec, screenshot area
      bind = SUPERCONTROL, Print, exec, screenshot

      # AUTOSTART
      # exec-once = hyprpaper
      # exec-once = hypridle
      # exec-once = dunst
      # exec-once = /usr/lib/polkit-kde-authentication-agent-1
      # exec-once = waybar
      # exec      = hyprshade auto
      exec-once = ags
    ''
  }
}
