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

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-monitored = {
      url = "github:ners/nix-monitored";
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

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      data = import ./secrets/data.nix;

      nixosSystem =
        name:
        nixpkgs.lib.nixosSystem {
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
        uranus = nixosSystem "uranus";
        titania = nixosSystem "titania";
        setebos = nixosSystem "setebos";
        oberon = nixosSystem "oberon";
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
