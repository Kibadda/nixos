{ pkgs, ... }: {
  imports = [
    ../../modules/hyprland/home.nix
    ../../modules/waybar/home.nix
    ../../modules/hyprpaper.nix
    ../../modules/chrome.nix
  ];

  home.packages = with pkgs; [
    chiaki
  ];

  wayland.windowManager.hyprland.settings = let
    coding = "name:Coding";
    games = "name:Games";
    tools = "name:Tools";
  in {
    env = [
      "LIBVA_DRIVER_NAME,nvidia"
      "XDG_SESSION_TYPE,wayland"
      "GBM_BACKEND,nvidia-drm"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "NIXOS_OZONE_WL,1"
    ];

    cursor = {
      no_hardware_cursors = true;
    };

    monitor = [
      "DP-2, 3840x2160@60, 0x0, 1.5"
      "DP-1, 2560x1440@60, 2560xß, 1"
    ];

    workspace = [
      "${coding}, monitor:DP-1, default:true"
      "${games}, monitor:DP-1"
      "${tools}, monitor:DP-1"
      "1, monitor:DP-2"
      "2, monitor:DP-2"
      "3, monitor:DP-2"
      "4, monitor:DP-2"
      "5, monitor:DP-2"
    ];

    bind = [
      "SUPER, C, workspace, ${coding}"
      "SUPER, G, workspace, ${games}"
      "SUPER, T, workspace, ${tools}"
    ];

    windowrulev2 = [
      "workspace ${coding}, class:^(kitty)$"
    ];
  };
}
