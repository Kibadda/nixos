{ inputs, config, pkgs, meta, ... }: {
  home = {
    username = meta.username;
    homeDirectory = "/home/${meta.username}";
  };

  programs = {
    waybar = (import ../../home/waybar/default.nix { inherit config pkgs; });
  };

  wayland.windowManager = {
    hyprland = (import ../../home/hyprland.nix { inherit config pkgs; });
  };
}
