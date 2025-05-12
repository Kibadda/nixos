{ meta, ... }:
{
  imports = [
    ../../modules/kibadda/home.nix
  ];

  kibadda = {
    chrome.enable = true;

    firefox = {
      enable = true;
      default = true;
    };

    vpn.enable = true;

    gaming.lutris = true;

    ssh = {
      enable = true;
      hosts = [
        {
          name = "uranus";
          host = "10.0.0.10";
          port = meta.sshPort;
        }
        {
          name = "pi";
          host = "10.0.0.2";
          port = meta.sshPort;
          forward = false;
        }
        {
          name = "oberon";
          host = "10.0.0.3";
          port = meta.sshPort;
          forward = false;
        }
        {
          name = meta.pi.forgejo.domain;
          port = meta.sshPort;
          forward = false;
        }
      ];
    };

    hypr = {
      enable = true;

      hypridle.enable = false;

      monitor = [
        "eDP-1, 1920x1080@60, 0x0, 1"
      ];

      waybar = {
        battery = true;
        backlight = true;
      };
    };
  };
}
