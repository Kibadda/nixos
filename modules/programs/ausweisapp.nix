{
  flake.nixosModules.ausweisapp = {
    programs.ausweisapp = {
      enable = true;
      openFirewall = true;
    };
  };
}
