{
  config,
  inputs,
  lib,
  secrets,
  self,
  ...
}:
{
  options = {
    nixosConfigurations = lib.mkOption {
      type = lib.types.lazyAttrsOf (
        lib.types.submodule {
          options = {
            disable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            system = lib.mkOption {
              type = lib.types.str;
            };
            configuration = lib.mkOption {
              type = lib.types.deferredModule;
            };
            home = lib.mkOption {
              type = lib.types.deferredModule;
            };
            nixosModules = lib.mkOption {
              type = lib.types.listOf lib.types.deferredModule;
            };
            homeModules = lib.mkOption {
              type = lib.types.listOf lib.types.deferredModule;
            };
            hardware = lib.mkOption {
              type = lib.types.nullOr lib.types.deferredModule;
              default = null;
            };
            disko = lib.mkOption {
              type = lib.types.nullOr lib.types.attrs;
              default = null;
            };
            nixpkgs = lib.mkOption {
              type = lib.types.package;
              default = inputs.nixpkgs;
            };
          };
        }
      );
    };
  };

  config.flake = {
    nixosConfigurations =
      lib.flip lib.mapAttrs (lib.filterAttrs (_: v: !v.disable) config.nixosConfigurations)
        (
          name:
          {
            system,
            configuration,
            home,
            nixosModules,
            homeModules,
            nixpkgs,
            hardware ? null,
            disko ? null,
            disable ? false,
          }:
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              selfpkgs = self.packages.${system};
            };
            modules = [
              configuration
              {
                imports = [
                  inputs.home-manager.nixosModules.home-manager
                ];

                networking.hostName = name;
                nixpkgs.hostPlatform = system;

                system.stateVersion = "24.05";

                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    selfpkgs = self.packages.${system};
                  };
                  users.${secrets.base.username} = {
                    imports = [
                      home
                    ]
                    ++ homeModules;
                    programs.home-manager.enable = true;
                    home.stateVersion = "24.05";
                  };
                };
              }
            ]
            ++ (lib.optional (disko != null) {
              imports = [
                inputs.disko.nixosModules.default
              ];

              inherit disko;
            })
            ++ (lib.optional (hardware != null) hardware)
            ++ nixosModules;
          }
        );
  };
}
