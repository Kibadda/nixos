{
  description = "Top level NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    server-nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable-nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    linphone-nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";

    mobile-nixpkgs.url = "github:nixos/nixpkgs?rev=f02fddb8acef29a8b32f10a335d44828d7825b78";
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos";
      flake = false;
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    powermenu.url = "github:Kibadda/powermenu";
    dmenu.url = "github:Kibadda/dmenu";
    passmenu.url = "github:Kibadda/passmenu";
    pinentry.url = "github:Kibadda/adw-pinentry";
    work.url = "github:Kibadda/work";
  };

  outputs =
    { self, ... }@inputs:
    let
      secrets = {
        base = import ./secrets/base.nix;
        home = import ./secrets/home.nix;
        pi = import ./secrets/pi.nix;
        work = import ./secrets/work.nix;
      };

      nixosSystem =
        {
          hostname,
          system ? "x86_64-linux",
          nixpkgs ? inputs.nixpkgs,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs secrets hostname;
          };
          modules = [ ./machines/${hostname}/configuration.nix ];
        };
    in
    {
      nixosConfigurations = {
        # Home PC
        uranus = nixosSystem {
          hostname = "uranus";
        };
        # Laptop
        titania = nixosSystem {
          hostname = "titania";
        };
        # Work
        setebos = nixosSystem {
          hostname = "setebos";
        };
        # Raspberry Pi 1
        oberon = nixosSystem {
          hostname = "oberon";
          system = "aarch64-linux";
          nixpkgs = inputs.server-nixpkgs;
        };
        # Raspberry Pi 2
        umbriel = nixosSystem {
          hostname = "umbriel";
          system = "aarch64-linux";
          nixpkgs = inputs.server-nixpkgs;
        };
        # OnePlus 6
        # ophelia = nixosSystem {
        #   hostname = "ophelia";
        #   system = "aarch64-linux";
        #   nixpkgs = inputs.mobile-nixpkgs;
        # };
      };

      devShells =
        let
          system = "x86_64-linux";
        in
        {
          ${system}.default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
            name = "nixos";
          };
        };
    };
}
