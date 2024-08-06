{ pkgs, config, inputs, ... }: let
  cfg = config.kibadda.neovim;
in {
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
      NEOVIM_DIR = cfg.dir;
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
