{
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko

    ./hardware-configuration.nix
    ./disko-config.nix

    ../common/desktop.nix
    ../common/configuration.nix
    ../common/home.nix

    ../../modules/kibadda/configuration.nix
  ];
}
