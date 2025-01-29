{
  inputs,
  meta,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  options = {
    home = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs meta;
      };

      users.${meta.username} = lib.attrsets.recursiveUpdate config.home {
        home.stateVersion = "24.05";
        programs.home-manager.enable = true;
      };
    };
  };
}
