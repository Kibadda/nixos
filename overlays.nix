{ inputs, ... }: {
  additions = final: prev: {
    kibadda = {
      dmenu = inputs.dmenu.defaultPackage.${prev.system};
      powermenu = inputs.powermenu.defaultPackage.${prev.system};
      passmenu = inputs.passmenu.defaultPackage.${prev.system};
      nvim = inputs.nvim.packages.${prev.system}.nvim;
    };
  };

  modifications = final: prev: {};

  unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
