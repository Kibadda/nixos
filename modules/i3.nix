{ lib, pkgs, config, meta, ... }: let
  cfg = config.kibadda;

  wallpaper = ".config/i3/wallpaper.png";
in {
  config = lib.mkIf cfg.i3.enable {
    services.xserver.windowManager.i3.enable = true;

    home-manager.users.${meta.username} = {
      services.picom.enable = true;

      xsession.windowManager.i3 = let
        modifier = "Mod4";
        darkblue = "#08052b";
        lightblue = "#5294e2";
        urgentred = "#e53935";
        white = "#ffffff";
        black = "#000000";
        darkgrey = "#383c4a";
        grey = "#b0b5bd";
        mediumgrey = "#8b8b8b";
        yellowbrown = "#E1B700";
        purple = "#E345FF";
      in {
        enable = true;
        config = {
          modifier = modifier;
          gaps = {
            inner = 6;
            outer = 3;
          };
          keybindings = {
            "${modifier}+1" = "workspace 1";
            "${modifier}+2" = "workspace 2";
            "${modifier}+3" = "workspace 3";
            "${modifier}+4" = "workspace 4";
            "${modifier}+5" = "workspace 5";
            "${modifier}+6" = "workspace 6";
            "${modifier}+Shift+1" = "move container to workspace 1; workspace 1";
            "${modifier}+Shift+2" = "move container to workspace 2; workspace 2";
            "${modifier}+Shift+3" = "move container to workspace 3; workspace 3";
            "${modifier}+Shift+4" = "move container to workspace 4; workspace 4";
            "${modifier}+Shift+5" = "move container to workspace 5; workspace 5";
            "${modifier}+Shift+6" = "move container to workspace 6; workspace 6";

            "${modifier}+Return" = "exec --no-startup-id kitty";
            "${modifier}+Shift+Space" = "exec --no-startup-id playerctl -p spotify play-pause";
            "${modifier}+Shift+Mod1+j" = "exec --no-startup-id playerctl -p spotify next";
            "${modifier}+Shift+Mod1+k" = "exec --no-startup-id playerctl -p spotify previous";
            "${modifier}+Shift+Mod1+h" = "exec --no-startup-id playerctl -p spotify position 15-";
            "${modifier}+Shift+Mod1+l" = "exec --no-startup-id playerctl -p spotify position 15+";
            "${modifier}+q" = "kill";
            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+r" = "restart";

            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";

            "${modifier}+Shift+h" = "move left";
            "${modifier}+Shift+j" = "move down";
            "${modifier}+Shift+k" = "move up";
            "${modifier}+Shift+l" = "move right";

            "${modifier}+f" = "fullscreen toggle";
            "${modifier}+Shift+f" = "floating toggle";
            "${modifier}+s" = "layout stacking";
            "${modifier}+g" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";


            "XF86AudioLowerVolume" = "exec --no-startup-id pamixer -d 5";
            "XF86AudioRaiseVolume" = "exec --no-startup-id pamixer -i 5";
            # "XF86AudioMute" = "exec --no-startup-id ~/.config/i3/scripts/volume_brightness.sh volume_mute";

            "${modifier}+r" = "mode resize";
          };
          modes = {
            resize = {
              h = "resize shrink width 10 px or 10 ppt";
              j = "resize grow height 10 px or 10 ppt";
              k = "resize shrink height 10 px or 10 ppt";
              l = "resize grow width 10 px or 10 ppt";
              Return = "mode default";
              Escape = "mode default";
            };
          };
          colors = {
            focused = {
              border = lightblue;
              background = darkblue;
              text = white;
              indicator = mediumgrey;
              childBorder = mediumgrey;
            };
            focusedInactive = {
              border = darkblue;
              background = darkblue;
              text = grey;
              indicator = black;
              childBorder = black;
            };
            unfocused = {
              border = darkblue;
              background = darkblue;
              text = grey;
              indicator = darkgrey;
              childBorder = darkgrey;
            };
            urgent = {
              border = urgentred;
              background = urgentred;
              text = white;
              indicator = yellowbrown;
              childBorder = yellowbrown;
            };
          };
          bars = [
            {
              colors  = {
                activeWorkspace = {
                  background = mediumgrey;
                  border = lightblue;
                  text = darkgrey;
                };
                background = darkgrey;
                focusedWorkspace = {
                  background = grey;
                  border = mediumgrey;
                  text = darkgrey;
                };
                inactiveWorkspace = {
                  background = darkgrey;
                  border = darkgrey;
                  text = grey;
                };
                separator = purple;
                statusline = white;
                urgentWorkspace = {
                  background = urgentred;
                  border = urgentred;
                  text = white;
                };
              };
              position = "top";
              statusCommand = "i3blocks";
              trayOutput = "primary";
              trayPadding = 0;
              extraConfig = ''
                font pango: Noto Sans Regular 15
              '';
            }
          ];
          startup = [
            { command = "setxkbmap -option 'caps:swapescape'"; notification = false; }
            { command = "numlockx on"; notification = false; }
            { command = "sleep 1 && feh --bg-fill ${wallpaper}"; notification = false; }
          ];
        };
        extraConfig = ''
          font pango: Noto Sans Regular 10
          workspace_layout default
          new_window pixel 1

          # exec --no-startup-id /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
          # exec --no-startup-id dex --autostart --environment i3
          #
          # exec --no-startup-id xset s 480 dpms 600 600 600
          #
          # exec --no-startup-id /usr/bin/dunst
          #
          # bindsym $mod+d exec --no-startup-id rofi -modi drun -show drun \
          # 		-config ~/.config/rofi/rofidmenu.rasi
          #
          # bindsym $mod+t exec --no-startup-id rofi -show window \
          # 		-config ~/.config/rofi/rofidmenu.rasi
          #
          # bindsym $mod+minus scratchpad show
          # bindsym $mod+Shift+minus move scratchpad
          # for_window [class="Spotify"] move scratchpad
        '';
      };

      home.file = {
        ${wallpaper} = {
          source = cfg.wallpaper;
        };

        ".local/bin/i3blocks-yubikey" = {
          executable = true;
          source = ../bin/yubikey-indicator.sh;
        };

        ".local/bin/i3blocks-spotify" = {
          executable = true;
          source = ../bin/spotify-indicator.sh;
        };
      };

      programs.i3blocks = {
        enable = true;
        bars = {
          top = {
            yubikey = {
              command = "yubikey-indicator.sh";
              interval = "persist";
              color = "#FFFF00";
            };
            spotify = {
              command = "spotify-indicator.sh";
              interval = 1;
              color = "#1DB954";
            };
            # disk = lib.hm.dag.entryAfter [ "spotify" ] {
            #   label = "";
            #   instance = "/";
            #   command = ~/.config/i3/scripts/disk;
            #   interval = 30;
            # };
          };
        };
      };
    };
  };
}
