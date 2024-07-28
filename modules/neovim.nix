{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [
    tree-sitter
    lua-language-server
    nodePackages.intelephense
    typescript-language-server
    stylua
    gcc
    nil
  ];

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = inputs.neovim-nightly.packages.${pkgs.system}.default;
  };
}
