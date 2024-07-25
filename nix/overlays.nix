{ inputs, ... }: {
  additions = final: prev: {};

  modifications = final: prev: {};

  unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
