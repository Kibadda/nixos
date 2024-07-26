{ inputs, config, pkgs, meta, ... }: {
  imports = [
    ../../modules/hyprland/home.nix
    ../../modules/waybar/home.nix
  ];
}
