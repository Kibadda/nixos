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

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    powermenu.url = "github:Kibadda/powermenu";
    dmenu.url = "github:Kibadda/dmenu";
    pinentry.url = "github:Kibadda/pinentry";
  };

  outputs = { self, nixpkgs, disko, home-manager, ... }@inputs: let
    inherit (self) outputs;

    hosts = [
      "uranus"
      "titania"
      "work"
    ];

    data = {
      username = "michael";
      name = "Michael Strobel";
      keyid = "0x3B6861376B6D3D78";
      email = "mstrobel97@gmail.com";
    };
  in {
    overlays = import ./overlays.nix { inherit inputs; };

    nixosConfigurations = builtins.listToAttrs (map (name: let 
      meta = { hostname = name; } // data;
    in {
      name = name;
      value = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs meta;
        };

        system = "x86_64-linux";

        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${meta.username} = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit inputs meta; };
          }
        ];
      };
    }) hosts);
  };
}
