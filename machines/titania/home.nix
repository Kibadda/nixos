{
  secrets,
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

    vpn.enable = true;

    gaming = {
      bottles = true;
      lutris = true;
    };

    ssh = {
      enable = true;
      hosts = [
        {
          name = "uranus";
          host = "10.0.0.10";
          port = secrets.home.sshPort;
        }
        {
          name = "pi";
          host = "10.0.0.2";
          port = secrets.home.sshPort;
          forward = false;
        }
        {
          name = "oberon";
          host = "10.0.0.3";
          port = secrets.home.sshPort;
          forward = false;
        }
        {
          name = "umbriel";
          host = "10.0.0.4";
          port = secrets.home.sshPort;
          forward = false;
        }
        {
          name = secrets.pi.forgejo.domain;
          port = secrets.home.sshPort;
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
          top = {
            modules-left = [ "hyprland/workspaces" ];
            modules-right = [
              "battery"
              "backlight"
              "bluetooth"
              "cpu"
              "memory"
              "disk"
              "pulseaudio"
              "network"
            ];
          };
          bottom = {
            modules-left = [ "custom/spotify" ];
            modules-center = [ "custom/yubikey" ];
            modules-right = [ "clock" ];
          };
        };
      };
  };
}
