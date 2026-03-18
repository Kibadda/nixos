{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    server-nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    work.url = "github:Kibadda/work";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs =
    inputs:
    let
      secrets = {
        base = import ./secrets/base.nix;
        pi = import ./secrets/pi.nix;
        home = import ./secrets/home.nix;
        work = import ./secrets/work.nix;
      };
    in
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = { inherit secrets; };
    } (inputs.import-tree ./modules);
}
