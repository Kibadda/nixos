{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    server-nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    mobile-nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "server-nixpkgs";
    };
    mobile-nixos = {
      url = "github:mobile-nixos/mobile-nixos";
      flake = false;
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
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
