{
  imports = [
    ../../modules/hyprland/default.nix
  ];

  programs.steam.enable = true;

  hardware.nvidia.modesetting.enable = true;
}
