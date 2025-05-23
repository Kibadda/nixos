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

    hypr =
      let
        coding = "name:Coding";
        games = "name:Games";
        tools = "name:Tools";
      in
      {
        enable = true;

        hypridle.enable = false;

        monitor = [
          "eDP-1, 1920x1080@60, 0x0, 1"
        ];

        bind = [
          "SUPER, C, workspace, ${coding}"
          "SUPER SHIFT, C, movetoworkspace, ${coding}"
          "SUPER, G, workspace, ${games}"
          "SUPER SHIFT, G, movetoworkspace, ${games}"
          "SUPER, T, workspace, ${tools}"
          "SUPER SHIFT, T, movetoworkspace, ${tools}"
        ];

        windowrule = [
          "workspace ${coding}, class:^(kitty)$"

          "workspace ${tools}, class:^(org.telegram.desktop)$"
          "workspace ${tools}, class:^(net.lutris.Lutris)$"
          "workspace ${games}, class:^(battle.net.exe)$"

          "workspace ${games}, class:^(hearthstone.exe)$"
          "fullscreen, class:^(hearthstone.exe)$"
        ];

        waybar = {
          battery = true;
          backlight = true;
        };
      };
  };
}
