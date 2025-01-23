{ lib, config, meta, ... }: let
  cfg = config.kibadda;
in {
  imports = [
    ../hypr/home.nix
    ../i3/home.nix
    ../zsh/home.nix
    ../yubikey/home.nix
    ../git.nix
    ../kitty.nix
    ../dunst.nix
    ../eza.nix
    ../pass.nix
    ../direnv.nix
    ../ssh.nix
    ../zoxide.nix
    ../neovim.nix
    ../firefox.nix
    ../chrome.nix
    ../font.nix
  ];

  options.kibadda = {
    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = ../../wallpapers/forest.png;
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
  };

  config = {
    home = {
      username = meta.username;

      homeDirectory = "/home/${meta.username}";

      packages = cfg.packages;

      sessionVariables = {
        NIXOS_DIR = "$HOME/.dotfiles";
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];

      file.".local/bin/fetch-repositories" = {
        executable = true;
        source = ../../bin/fetch-repositories.sh;
      };
    };

    xdg.enable = true;
  };
}
