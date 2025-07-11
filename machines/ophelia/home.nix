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
  # - waybar portait top bar full
  # - mouse support?
  # - hyprgrass

  home.packages = [
    pkgs.kibadda.ophelia-landscape-toggle
  ];

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

      device = [
        {
          name = "synaptics-s3706b";
          transform = 1;
        }
      ];

      bind = [
        "SUPER, m, exec, ${pkgs.kibadda.ophelia-landscape-toggle}/bin/ophelia-landscape-toggle"
        "SUPER SHIFT, Down, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%-"
        "SUPER SHIFT, Up, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%+"
      ];

      hyprlock.enable = false;
      hypridle.enable = false;

      waybar = {
        battery = true;
        backlight = true;
        spotify = false;
        yubikey = false;

        extraCss =
          let
            margin = "50px";
          in
          ''
            #workspaces,
            #spotify {
              margin-left: ${margin};
            }

            #network,
            #clock {
              margin-right: ${margin};
            }
          '';
      };
    };
  };
}
