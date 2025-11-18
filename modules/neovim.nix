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
      packages = [ pkgs.kibadda.nvimupdate ];

      sessionVariables = {
        EDITOR = "nvim";
        NEOVIM_DIR = "$HOME/Projects/neovim";
        MANPAGER = "nvim --cmd 'lua vim.g.loaded_starter = 1' +Man!";
      };

      sessionPath = [
        "${config.home.sessionVariables.NEOVIM_DIR}/bin"
      ];
    };
  };
}
