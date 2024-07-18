{
  description = "Top level NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    ags.url = "github:Aylur/ags";
  };

  outputs = { self, nixpkgs, disko, home-manager, ags, ... }@inputs: let
    inherit (self) outputs;

    systems = [
      "x86_64-linux"
    ];

    hosts = [
      "uranus"
      "titania"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    overlays = import ./overlays { inherit inputs; };
    
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.{$system});

    nixosConfigurations = builtins.listToAttrs (map (name: {
      name = name;
      value = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          meta = { hostname = name; };
        };

        system = "x86_64-linux";

        modules = [
          disko.nixosModules.disko
          ./machines/${name}/hardware-configuration.nix
          ./machines/${name}/disko-config.nix
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.userUserPackages = true;
            home-manager.users.michael = import ./home/home.nix;
            home-manager.extraSpecialArtgs = { inherit inputs; };
          }
        ];
      };
    }) hosts);
  };
}
