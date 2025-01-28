{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.neovim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.neovim.enable {
    home = {
      packages = [ pkgs.kibadda.nvim ];

      sessionVariables = {
        NIXVIM_DIR = "$HOME/Projects/nixvim";
        NEOVIM_DIR = "$HOME/Projects/neovim";
        MANPAGER = "nvim --cmd 'lua vim.g.loaded_starter = 1' +Man!";
      };
    };

    programs.zsh.shellAliases = {
      dev = "nix run $NIXVIM_DIR#nvim-dev --";
      buildnvim = "nix run $NIXVIM_DIR#nvim --override-input neovim-src $NEOVIM_DIR --";
      makenvim = "nix-shell -p gnumake cmake gettext python3";
    };
  };
}
