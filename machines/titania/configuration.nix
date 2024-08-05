{
  imports = [
    ../../modules/hypr.nix
  ];

  kibadda.hypr = {
    enable = true;
    settings = {
      input.touchpad = {
        natural_scroll = true;
        tap-to-click = true;
      };

      monitor = [
        "eDP-1, 1920x1080@60, 0x0, 1"
      ];
    };
    waybar = {
      battery = true;
      backlight = true;
    };
  };
}
