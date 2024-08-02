{ inputs, pkgs, ... }: {
  home = {
    packages = with pkgs; [
      tree-sitter
      gcc

      lua-language-server
      nodePackages.intelephense
      typescript-language-server
      nil

      stylua
    ];

    sessionVariables = {
      MANPAGER = "nvim +Man!";
      NEOVIM_DIR = "$HOME/Projects/neovim";
    };

    file.".local/bin/nvimupdate" = {
      executable = true;
      source = ../bin/nvimupdate.sh;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = inputs.neovim-nightly.packages.${pkgs.system}.default;
  };
}
