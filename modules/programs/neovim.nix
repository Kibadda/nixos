{
  secrets,
  ...
}:
{
  flake.homeModules.neovim =
    {
      config,
      lib,
      pkgs,
      selfpkgs,
      ...
    }:
    {
      home = {
        packages = with pkgs; [
          selfpkgs.nvimupdate
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

        file."intelephense/licence.txt".text = secrets.base.intelephenseLicense;
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
