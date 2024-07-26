{
  imports = [
    ../../modules/hyprland/home.nix
    ../../modules/waybar/home.nix
    ../../modules/hyprpaper/home.nix
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
}
