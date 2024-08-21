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
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";

    nvim.url = "github:Kibadda/nixvim";
    powermenu.url = "github:Kibadda/powermenu";
    dmenu.url = "github:Kibadda/dmenu";
    passmenu.url = "github:Kibadda/passmenu";
    pinentry.url = "github:Kibadda/pinentry";
  };

  outputs = { self, nixpkgs, disko, home-manager, raspberry-pi-nix, ... }@inputs: let
    inherit (self) outputs;

    data = import ./secrets/data.nix;

    mkNixosSystem = { name, system, extraModules ? [], extraHomeModules ? [] }: let
      meta = { hostname = name; } // data;
    in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs outputs meta; };

        modules = extraModules ++ [
          ./configuration.nix
          ./modules/kibadda/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs meta; };
            home-manager.users.${meta.username} = {
              imports = [
                ./modules/kibadda/home.nix
              ] ++ extraHomeModules;

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

    mkDesktopSystem = name: mkNixosSystem {
      inherit name;
      system = "x86_64-linux";
      extraModules = [
        disko.nixosModules.disko
        ./desktop.nix
        ./machines/${name}/disko-config.nix
        ./machines/${name}/hardware-configuration.nix
        ./machines/${name}/configuration.nix
      ];
      extraHomeModules = [
        ./machines/${name}/home.nix
      ];
    };

    mkPiSystem = name: mkNixosSystem {
      inherit name;
      system = "aarch64-linux";
      extraModules = [
        raspberry-pi-nix.nixosModules.raspberry-pi
        {
          raspberry-pi-nix.board = "bcm2711";
        }
      ];
      extraHomeModules = [
        ./machines/pi/home.nix
      ];
    };
  in {
    overlays = import ./overlays.nix { inherit inputs; };

    nixosConfigurations = {
      uranus = mkDesktopSystem "uranus";
      titania = mkDesktopSystem "titania";
      work = mkDesktopSystem "work";

      pi = mkPiSystem "pi";
    };

    devShells."x86_64-linux".default = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in pkgs.mkShell {
      name = "nixos-devShell";
      buildInputs = [];
    };
  };
}
