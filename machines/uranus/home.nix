{ pkgs, inputs, meta, ... }: {
  home = {
    packages = [ pkgs.sshfs ];
  };

  kibadda = {
    packages = with pkgs; [
      chiaki
    ];

    browser = "chrome";

    nvimPackage = inputs.nvim.packages.${pkgs.system}.nvim-dev;

    ssh = [
      {
        name = "titania";
        host = "10.0.0.11";
        port = meta.sshPort;
      }
      {
        name = "pi";
        host = "10.0.0.2";
        port = meta.sshPort;
        forward = false;
      }
      {
        name = "work-studies";
        host = meta.work.sshfs.studies;
        user = meta.work.sshfs.user;
        forward = false;
      }
    ];

    hypr = let
      coding = "name:Coding";
      games = "name:Games";
      tools = "name:Tools";

      monitorLeft = "DP-2";
      monitorRight = "DP-1";
    in {
      enable = true;

      nvidia = true;

      monitor = [
        "${monitorLeft}, 3840x2160@60, 0x0, 1.5"
        "${monitorRight}, 2560x1440@60, 2560x0, 1"
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
        "workspace ${tools}, class:^(steam)$"
        "workspace ${games}, class:^(steam.+)$"

        "workspace ${games}, class:^(Last Epoch.x86_64)$"
        "fullscreen, class:^(Last Epoch.x86_64)"

        "stayfocused, title:^()$, class:^(steam)$"
        "minsize 1 1, title:^()$, class:^(steam)$"

        "workspace ${games}, class:^(chiaki)$"
      ];

      workspace = [
        "${coding}, monitor:${monitorRight}, default:true"
        "${games}, monitor:${monitorRight}"
        "${tools}, monitor:${monitorRight}"
        "1, monitor:${monitorLeft}"
        "2, monitor:${monitorLeft}"
        "3, monitor:${monitorLeft}"
        "4, monitor:${monitorLeft}"
        "5, monitor:${monitorLeft}"
      ];
    };
  };
}
