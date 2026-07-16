{
  flake.nixosModules.it-tools =
    {
      pkgs,
      ...
    }:
    {
      kibadda.services.it-tools = {
        description = "IT Tools";
        subdomain = "tools";
        open = true;
        auth = "none";
        extra = ''
          root * ${pkgs.it-tools}/lib
          file_server
        '';
        section = "Tools";
      };
    };
}
