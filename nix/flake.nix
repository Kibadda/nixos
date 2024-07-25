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
  };

  outputs = { self, nixpkgs, disko, home-manager, ... }@inputs: let
    inherit (self) outputs;

    systems = [
      "x86_64-linux"
    ];

    hosts = [
      # "uranus"
      "titania"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    data = {
      username = "michael";
      name = "Michael Strobel";
      key = "0x3B6861376B6D3D78";
      email = "mstrobel97@gmail.com";
    };
  in {
    overlays = import ./overlays.nix { inherit inputs; };
    
    packages = forAllSystems (system: import ./pkgs.nix nixpkgs.legacyPackages.${system});

    nixosConfigurations = builtins.listToAttrs (map (name: let 
      meta = { hostname = name; } // data;
    in {
      name = name;
      value = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          meta = meta;
        };

        system = "x86_64-linux";

        modules = [
          disko.nixosModules.disko
          ./machines/${name}/hardware-configuration.nix
          ./machines/${name}/disko-config.nix
          ./machines/${name}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${meta.username} = import ./machines/${name}/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs meta; };
          }
        ];
      };
    }) hosts);
  };
}
