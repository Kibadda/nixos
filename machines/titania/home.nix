{ meta, pkgs, ... }: {
  home.packages = with pkgs; [
    lutris
  ];

  kibadda = {
    chrome.enable = true;

    ssh = [
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
    ];

    hypr = {
      enable = true;

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
