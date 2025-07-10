{
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/kibadda/home.nix
  ];

  # TODO
  # - keyboard?
  # - waybar padding corners
  # - mouse support?
  # - backlight change?
  # - hyprgrass

  kibadda = {
    firefox = {
      enable = true;
      default = true;
    };

    neovim.enable = false;

    yubikey.enable = false;

    hypr = {
      enable = true;

      monitor = [
        "DSI-1, 1080x2280@60, 0x0, 1, transform, 1"
      ];

      hyprlock.enable = false;
      hypridle.enable = false;

      waybar = {
        battery = true;
        backlight = true;
        spotify = false;
        yubikey = false;
      };
    };
  };
}
