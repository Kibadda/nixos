{
  imports = [
    ../../modules/hyprland/home.nix
    ../../modules/waybar/home.nix
    ../../modules/hyprpaper.nix
    ../../modules/chrome.nix
  ];

  wayland.windowManager.hyprland.settings = {
    input.touchpad = {
      natural_scroll = true;
      tap-to-click = true;
    };

    monitor = [
      "eDP-1, 1920x1080@60, 0x0, 1"
    ];
  };

  programs.waybar.settings.top = {
    modules-right = [
      "battery"
      "backlight"
    ];

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
}
