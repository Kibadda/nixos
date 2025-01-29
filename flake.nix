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

      nixosSystem =
        {
          name,
          system ? "x86_64-linux",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs;
            meta = {
              hostname = name;
            } // data;
          };
          modules = [ ./machines/${name}/configuration.nix ];
        };
    in
    {
      nixosConfigurations = {
        uranus = nixosSystem { name = "uranus"; };
        titania = nixosSystem { name = "titania"; };
        setebos = nixosSystem { name = "setebos"; };

        pi = nixosSystem {
          name = "pi";
          system = "aarch64-linux";
        };
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
