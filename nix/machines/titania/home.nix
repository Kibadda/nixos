{ inputs, config, pkgs, meta, ... }: {
  # move this to separate hyprland/home.nix?
  programs = {
    waybar = (import ../../home/waybar/default.nix { inherit config pkgs; });
  };

  wayland.windowManager = {
    hyprland = (import ../../home/hyprland.nix { inherit config pkgs; });
  };
}
