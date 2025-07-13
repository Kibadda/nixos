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

    kitty.size = 18;

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

      # FIX: make this work again
      hyprpaper.enable = false;
      hyprlock.enable = false;
      hypridle.enable = false;

      waybar = {
        top = {
          modules-left = [ "hyprland/workspaces" ];
          modules-right = [
            "battery"
            "backlight"
            # FIX: sound not working
            # "pulseaudio"
            "network"
          ];
        };
        bottom = {
          modules-left = [ "bluetooth" ];
          modules-center = [
            "cpu"
            "memory"
            "disk"
          ];
          modules-right = [ "clock" ];
        };

        extraCss =
          let
            margin = "50px";
          in
          ''
            .modules-left {
              margin-left: ${margin};
            }
            .modules-right {
              margin-right: ${margin};
            }
          '';
      };
    };
  };
}
