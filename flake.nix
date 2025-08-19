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

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";

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

    nvim.url = "github:Kibadda/nixvim";
    powermenu.url = "github:Kibadda/powermenu";
    dmenu.url = "github:Kibadda/dmenu";
    passmenu.url = "github:Kibadda/passmenu";
    pinentry.url = "github:Kibadda/pinentry";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      secrets = {
        base = import ./secrets/base.nix;
        home = import ./secrets/home.nix;
        pi = import ./secrets/pi.nix;
        work = import ./secrets/work.nix;
      };

      nixosSystem =
        hostname: system:
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
        uranus = nixosSystem "uranus" "x86_64-linux";
        # Laptop
        titania = nixosSystem "titania" "x86_64-linux";
        # Work
        setebos = nixosSystem "setebos" "x86_64-linux";
        # Raspberry Pi 1
        oberon = nixosSystem "oberon" "aarch64-linux";
        # Raspberry Pi 2
        umbriel = nixosSystem "umbriel" "aarch64-linux";
        # OnePlus 6
        ophelia = nixosSystem "ophelia" "aarch64-linux";
      };

      devShells =
        let
          system = "x86_64-linux";
        in
        {
          ${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
            name = "nixos";
          };
        };
    };
}
