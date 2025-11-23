{
  pkgs,
  lib,
  config,
  secrets,
  ...
}:
let
  cfg = config.home-manager.users.${secrets.base.username}.kibadda;

  reset-keybindings = import ./reset-keybindings.nix { inherit lib; };
in
{
  config = lib.mkIf cfg.gnome.enable {
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
        gnomeExtensions.spotify-tray
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

      etc."wallpaper/forest.png".source = ../../wallpapers/forest.png;
    };

    programs.dconf = {
      enable = true;
      profiles.user.databases = [
        {
          settings = lib.recursiveUpdate reset-keybindings {
            "system/locale" = {
              region = "de_DE.UTF-8";
            };

            "org/gnome/mutter" = {
              experimental-features = [
                "scale-monitor-framebuffer"
              ];
            };

            "org/gnome/mutter/keybindings" = {
              toggle-tiled-left = [ "<Control><Super>h" ];
              toggle-tiled-right = [ "<Control><Super>l" ];
            };

            "org/gnome/desktop/background" = {
              picture-uri = "file:///etc/wallpaper/forest.png";
              picture-uri-dark = "file:///etc/wallpaper/forest.png";
            };

            "org/gnome/desktop/calendar" = {
              show-weekdate = true;
            };

            "org/gnome/desktop/wm/preferences" = {
              audible-bell = false;
            };

            "org/gnome/desktop/interface" = {
              accent-color = "green";
              color-scheme = "prefer-dark";
              clock-show-seconds = true;
              clock-show-weekday = true;
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

            "org/gnome/shell/extensions/sp-tray" = {
              display-format = "{artist} | {track}";
              podcast-format = "{album} | {track}";
              display-mode = lib.gvariant.mkInt32 0;
              position = lib.gvariant.mkInt32 0;
              logo-position = lib.gvariant.mkInt32 0;
              artist-max-length = lib.gvariant.mkInt32 40;
              album-max-length = lib.gvariant.mkInt32 40;
              title-max-length = lib.gvariant.mkInt32 60;
              hidden-when-inactive = true;
              hidden-when-paused = false;
              metadata-when-paused = true;
              hidden-when-stopped = true;
            };

            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
              name = "kitty";
              command = "kitty";
              binding = "<Super>Return";
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
              name = "firefox";
              command = "firefox";
              binding = "<Super>B";
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
              name = "secret firefox";
              command = "firefox --private-window";
              binding = "<Shift><Super>B";
            };

            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = [
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
                "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
              ];
              www = [ "<Super>b" ];
              next = [ "AudioNext" ];
              play = [ "AudioPlay" ];
              previous = [ "AudioPrev" ];
              volume-down = [ "AudioLowerVolume" ];
              volume-up = [ "AudioRaiseVolume" ];
              volume-mute = [ "AudioMute" ];
            };

            "org/gnome/desktop/wm/keybindings" = {
              close = [ "<Super>Q" ];
              move-to-workspace-1 = [ "<Shift><Super>1" ];
              move-to-workspace-2 = [ "<Shift><Super>2" ];
              move-to-workspace-3 = [ "<Shift><Super>3" ];
              move-to-workspace-4 = [ "<Shift><Super>4" ];
              move-to-monitor-left = [ "<Shift><Super>h" ];
              move-to-monitor-right = [ "<Shift><Super>l" ];
              switch-to-workspace-1 = [ "<Super>1" ];
              switch-to-workspace-2 = [ "<Super>2" ];
              switch-to-workspace-3 = [ "<Super>3" ];
              switch-to-workspace-4 = [ "<Super>4" ];
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
        }
      ];
    };
  };
}
