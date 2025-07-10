{
  ...
}:
{
  imports = [
    ../../modules/kibadda/home.nix
  ];

  kibadda = {
    firefox = {
      enable = true;
      default = true;
    };

    neovim.enable = false;

    yubikey.enable = false;

    hypr = {
      enable = false;

      monitor = [
        "DSI-1, 1080x2280@60, 0x0, 1, transform, 1"
      ];

      hypridle.enable = false;

      waybar = {
        battery = true;
        backlight = true;
      };
    };
  };
}
