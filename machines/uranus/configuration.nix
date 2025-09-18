{
  imports = [
    ../common/desktop.nix
    ../common/configuration.nix
    ../common/home.nix

    ../../modules/kibadda/configuration.nix
  ];

  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };
}
