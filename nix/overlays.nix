{ inputs, ... }: {
  additions = finale: _prev: import ../pkgs final.pkgs;

  modifications = finale: prev: {};

  unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
