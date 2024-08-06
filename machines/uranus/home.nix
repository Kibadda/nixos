{ pkgs, ... }: {
  kibadda = {
    packages = with pkgs; [
      chiaki
    ];

    hypr = let
      coding = "name:Coding";
      games = "name:Games";
      tools = "name:Tools";

      monitorLeft = "DP-1";
      monitorRight = "DP-3";
    in {
      enable = true;

      nvidia = true;

      monitor = [
        "${monitorLeft}, 3840x2160@60, 0x0, 1.5"
        "${monitorRight}, 2560x1440@60, 2560x0, 1"
      ];

      bind = [
        "SUPER, C, workspace, ${coding}"
        "SUPER, G, workspace, ${games}"
        "SUPER, T, workspace, ${tools}"
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

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };
    };
  };
}
