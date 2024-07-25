{ inputs, config, pkgs, meta, ... }: {
  imports = [
    ../../home/home.nix
  ];

  programs = {
    waybar = (import ../../home/waybar/default.nix { inherit config pkgs; });
  };

  wayland.windowManager = {
    hyprland = (import ../../home/hyprland.nix { inherit config pkgs; });
  };
}
