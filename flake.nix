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

    nvim.url = "github:Kibadda/nixvim";

    powermenu.url = "github:Kibadda/powermenu";
    dmenu.url = "github:Kibadda/dmenu";
    passmenu.url = "github:Kibadda/passmenu";
    pinentry.url = "github:Kibadda/pinentry";
  };

  outputs = { self, nixpkgs, disko, home-manager, ... }@inputs: let
    inherit (self) outputs;

    hosts = [
      "uranus"
      "titania"
      "work"
    ];

    data = import ./secrets/data.nix;
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
            home-manager.extraSpecialArgs = { inherit inputs meta; };
            home-manager.users.${meta.username} = {
              imports = [
                ./modules/kibadda/home.nix
                ./machines/${meta.hostname}/home.nix
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
    }) hosts);
  };
}
