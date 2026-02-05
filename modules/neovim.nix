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
      packages = with pkgs; [
        kibadda.nvimupdate
        lua-language-server
        nodePackages.intelephense
        typescript-language-server
        nil
        stylua
        gcc
        tree-sitter
        nixfmt
        copilot-language-server
      ];

      sessionVariables = {
        EDITOR = "nvim";
        NEOVIM_DIR = "$HOME/Projects/neovim";
        MANPAGER = "nvim --cmd 'lua vim.g.loaded_starter = 1' +Man!";
      };

      sessionPath = [
        "${config.home.sessionVariables.NEOVIM_DIR}/bin"
      ];
    };

    programs = {
      git.settings = {
        "difftool \"nvim_difftool\"".cmd =
          "nvim --cmd \"lua vim.g.loaded_starter = 1\" -c \"packadd nvim.difftool\" -c \"DiffTool $LOCAL $REMOTE\"";
        diff.tool = "nvim_difftool";
      };
      zsh.initContent = # bash
        ''
          PATH="$PATH:${config.home.sessionVariables.NEOVIM_DIR}/bin"
        '';
    };
  };
}
