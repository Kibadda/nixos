{ lib, pkgs, config, meta, ... }: let
  cfg = config.kibadda;

  i3Module = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };
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
    ../font.nix
  ];

  options.kibadda = {
    i3 = lib.mkOption {
      type = i3Module;
      default = {};
    };

    wallpaper = lib.mkOption {
      type = lib.types.path;
      default = ../../wallpapers/forest.png;
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };

    browser = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "chrome" "firefox" ]);
      default = null;
    };
  };

  config = {
    home = {
      username = meta.username;

      homeDirectory = "/home/${meta.username}";

      packages = cfg.packages
        ++ (if cfg.browser == "chrome" then [ pkgs.google-chrome ] else [])
        ++ (if cfg.browser == "firefox" then [ pkgs.firefox ] else []);

      sessionVariables = {
        BROWSER = (if cfg.browser == "chrome" then "google-chrome-stable" else "firefox");
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
