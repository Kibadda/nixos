{
  lib,
  ...
}:
{
  config = {
    flake.nixosModules.gnome =
      {
        config,
        pkgs,
        ...
      }:
      {
        options.kibadda.gnome = {
          settings = lib.mkOption {
            type = lib.types.attrs;
            default = { };
          };

          reset = lib.mkOption {
            type = lib.types.attrs;
            default = { };
          };

          keybindings = lib.mkOption {
            type = lib.types.listOf (
              lib.types.submodule {
                options = {
                  name = lib.mkOption {
                    type = lib.types.str;
                  };

                  command = lib.mkOption {
                    type = lib.types.str;
                  };

                  binding = lib.mkOption {
                    type = lib.types.str;
                  };
                };
              }
            );
            default = [ ];
          };
        };

        config = {
          services = {
            displayManager.gdm.enable = true;
            desktopManager.gnome.enable = true;
            xserver.xkb.layout = "de";
          };

          environment = {
            systemPackages = with pkgs; [
              dconf-editor
              gnomeExtensions.focus-changer
              gnomeExtensions.system-monitor
              gnomeExtensions.auto-move-windows
              gnomeExtensions.clipboard-history
              gnomeExtensions.panel-date-format
              gnomeExtensions.paperwm
              gnomeExtensions.mpris-label
            ];

            gnome.excludePackages = with pkgs; [
              epiphany
              gnome-text-editor
              gnome-calculator
              gnome-connections
              gnome-characters
              gnome-clocks
              gnome-contacts
              gnome-font-viewer
              gnome-logs
              gnome-maps
              gnome-music
              gnome-weather
              simple-scan
              snapshot
              yelp
              seahorse
              geary
              gnome-tour
            ];

            etc = {
              "wallpaper/forest.png".source = ../../wallpapers/forest.png;
              "wallpaper/windmill.jpg".source = ../../wallpapers/windmill.jpg;
            };
          };

          programs.dconf = {
            enable = true;
            profiles.user.databases = [
              {
                settings =
                  let
                    keybindings = config.kibadda.gnome.keybindings ++ [
                      {
                        name = "kitty";
                        command = "kitty";
                        binding = "<Super>Return";
                      }
                      {
                        name = "firefox";
                        command = "firefox";
                        binding = "<Super>B";
                      }
                      {
                        name = "private firefox";
                        command = "firefox --private-window";
                        binding = "<Shift><Super>B";
                      }
                    ];

                    custom-keybindings =
                      (builtins.listToAttrs (
                        map (i: {
                          name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}";
                          value = lib.elemAt keybindings i;
                        }) (lib.range 0 (lib.length keybindings - 1))
                      ))
                      // {
                        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = map (
                          i: "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}/"
                        ) (lib.range 0 (lib.length keybindings - 1));
                      };

                    default-settings = {
                      "system/locale" = {
                        region = "de_DE.UTF-8";
                      };

                      "org/gnome/mutter" = {
                        experimental-features = [
                          "scale-monitor-framebuffer"
                        ];
                        workspaces-only-on-primary = true;
                        dynamic-workspaces = false;
                      };

                      "org/gnome/mutter/keybindings" = {
                        toggle-tiled-left = [ "<Control><Super>h" ];
                        toggle-tiled-right = [ "<Control><Super>l" ];
                      };

                      "org/gnome/desktop/background" = {
                        picture-uri = "file:///etc/wallpaper/windmill.jpg";
                        picture-uri-dark = "file:///etc/wallpaper/windmill.jpg";
                      };

                      "org/gnome/desktop/calendar" = {
                        show-weekdate = true;
                      };

                      "org/gnome/desktop/wm/preferences" = {
                        audible-bell = false;
                        num-workspaces = lib.gvariant.mkInt32 4;
                      };

                      "org/gnome/desktop/interface" = {
                        accent-color = "green";
                        color-scheme = "prefer-dark";
                        clock-show-seconds = true;
                        clock-show-weekday = true;
                        cursor-theme = "Bibata-Modern-Classic";
                        cursor-size = lib.gvariant.mkInt32 18;
                      };

                      "org/gnome/desktop/input-sources" = {
                        xkb-options = [ "caps:swapescape" ];
                        sources = [
                          (lib.gvariant.mkTuple [
                            "xkb"
                            "de"
                          ])
                        ];
                      };

                      "org/gnome/shell" = {
                        enabled-extensions = with pkgs; [
                          gnomeExtensions.focus-changer.extensionUuid
                          gnomeExtensions.system-monitor.extensionUuid
                          gnomeExtensions.auto-move-windows.extensionUuid
                          gnomeExtensions.clipboard-history.extensionUuid
                          gnomeExtensions.panel-date-format.extensionUuid
                          gnomeExtensions.mpris-label.extensionUuid
                          # gnomeExtensions.paperwm.extensionUuid
                        ];
                      };

                      "org/gnome/shell/extensions/focus-changer" = {
                        focus-up = [ "<Super>k" ];
                        focus-left = [ "<Super>h" ];
                        focus-down = [ "<Super>j" ];
                        focus-right = [ "<Super>l" ];
                      };

                      "org/gnome/shell/extensions/system-monitor" = {
                        show-cpu = true;
                        show-memory = true;
                        show-swap = false;
                        show-upload = true;
                        show-download = true;
                      };

                      "org/gnome/shell/extensions/auto-move-windows" = {
                        application-list = [
                          "firefox.desktop:1"
                          "steam.desktop:2"
                          "telegram.desktop:3"
                          "spotify.desktop:4"
                        ];
                      };

                      "org/gnome/shell/extensions/mpris-label" = {
                        auto-switch-to-most-recent = true;
                        extension-place = "left";
                        mpris-sources-whitelist = "Mozilla Firefox,Spotify";
                        use-whitelisted-sources-only = true;
                      };

                      "org/gnome/shell/extensions/panel-date-format" = {
                        format = "%A %d.%m.%Y %H:%M:%S";
                      };

                      "org/gnome/shell/extensions/clipboard-history" = {
                        paste-on-selection = false;
                        window-width-percentage = lib.gvariant.mkInt32 20;
                      };

                      "org/gnome/desktop/session" = {
                        idle-delay = lib.gvariant.mkInt32 600;
                      };

                      "org/gnome/settings-daemon/plugins/power" = {
                        sleep-inactive-ac-type = "nothing";
                      };

                      "org/gnome/settings-daemon/plugins/media-keys" = {
                        www = [ "<Super>b" ];
                        home = [ "<Super>f" ];
                        next = [ "AudioNext" ];
                        play = [ "AudioPlay" ];
                        previous = [ "AudioPrev" ];
                        volume-down = [ "AudioLowerVolume" ];
                        volume-up = [ "AudioRaiseVolume" ];
                        volume-mute = [ "AudioMute" ];
                        shutdown = [ "<Shift><Super>x" ];
                        reboot = [ "<Shift><Super>r" ];
                        logout = [ "<Shift><Super>e" ];
                        screensaver = [ "<Shift><Super>s" ];
                      };

                      "org/gnome/nautilus/preferences" = {
                        date-time-format = "detailed";
                      };

                      "org/gnome/nautilus/window-state" = {
                        maximized = true;
                      };

                      "org/gnome/desktop/wm/keybindings" = {
                        close = [ "<Super>Q" ];
                        move-to-workspace-1 = [ "<Shift><Super>1" ];
                        move-to-workspace-2 = [ "<Shift><Super>2" ];
                        move-to-workspace-3 = [ "<Shift><Super>3" ];
                        move-to-workspace-4 = [ "<Shift><Super>4" ];
                        move-to-workspace-left = [ "<Shift><Super>d" ];
                        move-to-workspace-right = [ "<Shift><Super>u" ];
                        move-to-monitor-left = [ "<Shift><Super>h" ];
                        move-to-monitor-right = [ "<Shift><Super>l" ];
                        switch-to-workspace-1 = [ "<Super>1" ];
                        switch-to-workspace-2 = [ "<Super>2" ];
                        switch-to-workspace-3 = [ "<Super>3" ];
                        switch-to-workspace-4 = [ "<Super>4" ];
                        switch-to-workspace-left = [ "<Super>d" ];
                        switch-to-workspace-right = [ "<Super>u" ];
                        switch-windows = [ "<Super>Tab" ];
                        switch-windows-backward = [ "<Shift><Super>Tab" ];
                        toggle-fullscreen = [ "<Shift><Super>space" ];
                        toggle-maximized = [ "<Super>space" ];
                      };

                      "org/gnome/shell/keybindings" = {
                        show-screenshot-ui = [ "Print" ];
                        screenshot-window = [ "<Control>Print" ];
                        screenshot = [ "<Shift>Print" ];
                      };
                    };
                  in
                  lib.lists.foldr (a: b: lib.recursiveUpdate a b) { } [
                    config.kibadda.gnome.reset
                    default-settings
                    config.kibadda.gnome.settings
                    custom-keybindings
                  ];
              }
            ];
          };

          kibadda.gnome.reset = {
            "org/gnome/shell/keybindings" = {
              show-screen-recording-ui = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
            };

            "org/gnome/settings-daemon/plugins/media-keys" = {
              battery-status = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              battery-status-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              calculator = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              calculator-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              control-center = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              control-center-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              decrease-text-size = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              eject = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              eject-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              email = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              email-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              help = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              hibernate = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              hibernate-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              home = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              home-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              increase-text-size = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              keyboard-brightness-down = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              keyboard-brightness-down-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              keyboard-brightness-toggle = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              keyboard-brightness-toggle-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              keyboard-brightness-up = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              keyboard-brightness-up-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              logout = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              magnifier = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              magnifier-zoom-in = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              magnifier-zoom-out = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              media = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              media-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              mic-mute = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              mic-mute-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              next-static = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              on-screen-keyboard = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              screenreader = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              screensaver = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
            };

            "org/gnome/desktop/wm/keybindings" = {
              activate-window-menu = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              always-on-top = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              begin-move = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              begin-resize = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              cycle-group = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              cycle-group-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              cycle-panels = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              cycle-windows = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              cycle-windows-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              lower = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              minimize = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-center = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-corner-ne = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-corner-nw = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-corner-se = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-corner-sw = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-monitor-down = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-left = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-right = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-monitor-up = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-side-e = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-side-n = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-side-s = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-side-w = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-5 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-6 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-7 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-8 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-9 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-10 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-11 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-12 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              maximize-horizontally = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              maximize-vertically = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-down = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-up = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              move-to-workspace-last = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              panel-run-dialog = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              raise = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              raise-or-lower = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              set-spew-mark = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              show-desktop = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-applications = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-applications-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-group = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-group-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-input-source = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-input-source-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-panels = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-panels-backward = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-5 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-6 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-7 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-8 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-9 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-10 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-11 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-12 = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-down = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-left = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-right = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-up = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              switch-to-workspace-last = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              maximize = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              toggle-on-all-workspaces = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              unmaximize = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
            };

            "org/gnome/mutter/wayland/keybindings" = {
              restore-shortcuts = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
            };

            "org/gnome/shell/keybindings" = {
              focus-active-notification = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              toggle-quick-settings = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              toggle-application-view = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
              toggle-message-tray = lib.gvariant.mkEmptyArray (lib.gvariant.type.string);
            };
          };
        };
      };
  };
}
