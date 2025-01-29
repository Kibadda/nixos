{
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko

    ./hardware-configuration.nix
    ./disko-configuration.nix

    ../common/base.nix
    ../common/desktop.nix
    ../common/home-manager.nix

    ../../modules2
  ];

  yubikey = {
    enable = true;
    touch-detector.enable = true;
  };

  hyprland.enable = true;
}
