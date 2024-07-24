{ inputs, ... }: {
  additions = final: _prev: import ./pkgs.nix final.pkgs;

  modifications = final: prev: {};

  unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
