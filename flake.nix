{
  description = "Top level NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    raspberry-pi-nix = {
      url = "github:nix-community/raspberry-pi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim = {
      url = "github:Kibadda/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    powermenu = {
      url = "github:Kibadda/powermenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dmenu = {
      url = "github:Kibadda/dmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    passmenu = {
      url = "github:Kibadda/passmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pinentry = {
      url = "github:Kibadda/pinentry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://raspberry-pi-nix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn9o="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      raspberry-pi-nix,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      data = import ./secrets/data.nix;

      mkNixosSystem =
        {
          name,
          system,
          modules ? [ ],
        }:
        let
          meta = {
            hostname = name;
          } // data;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs meta; };

          modules = modules ++ [
            ./machines/common/configuration.nix
            ./modules/kibadda/configuration.nix
            ./machines/${name}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs meta; };
              home-manager.users.${meta.username} = {
                imports = [
                  ./modules/kibadda/home.nix
                  ./machines/${name}/home.nix
                ];

                # It is occasionally necessary for Home Manager to change configuration
                # defaults in a way that is incompatible with stateful data. This could,
                # for example, include switching the default data format or location of a file.
                #
                # The state version indicates which default settings are in effect and
                # will therefore help avoid breaking program configurations. Switching
                # to a higher state version typically requires performing some manual
                # steps, such as data conversion or moving files.
                home.stateVersion = "24.05";
                programs.home-manager.enable = true;
              };
            }
          ];
        };

      mkDesktopSystem =
        name:
        mkNixosSystem {
          inherit name;
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./machines/common/desktop.nix
            ./machines/${name}/disko-config.nix
            ./machines/${name}/hardware-configuration.nix
          ];
        };

      mkPiSystem =
        name:
        mkNixosSystem {
          inherit name;
          system = "aarch64-linux";
          modules = [
            raspberry-pi-nix.nixosModules.raspberry-pi
          ];
        };
    in
    {
      overlays = import ./overlays.nix { inherit inputs; };

      nixosConfigurations = {
        uranus = mkDesktopSystem "uranus";
        titania = mkDesktopSystem "titania";
        setebos = mkDesktopSystem "setebos";

        pi = mkPiSystem "pi";
      };

      devShells."x86_64-linux".default =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        pkgs.mkShell {
          name = "nixos-devShell";
          buildInputs = [ ];
        };
    };
}
