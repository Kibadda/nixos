{ lib, pkgs, config, meta, ... }: let
  cfg = config.kibadda;

  cursorModule = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Bibata-Modern-Classic";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.bibata-cursors;
      };

      size = lib.mkOption {
        type = lib.types.int;
        default = 18;
      };
    };
  };

  waybarModule = lib.types.submodule {
    options = {
      battery = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      backlight = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  fontModule = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "JetBrainsMono";
      };

      pkg = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nerd-fonts.jetbrains-mono;
      };
    };
  };

  hyprModule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      nvidia = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      monitor = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      bind = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      windowrule = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      workspace = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      cursor = lib.mkOption {
        type = cursorModule;
        default = {};
      };

      waybar = lib.mkOption {
        type = waybarModule;
        default = {};
      };
    };
  };

  i3Module = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  yubikeyModule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      touch-detector = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      pam = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "sudo" "login" ];
      };
    };
  };

  kittyModule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      size = lib.mkOption {
        type = lib.types.int;
        default = 10;
      };
    };
  };

  sshModule = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
      };

      host = lib.mkOption {
        type = lib.types.str;
      };

      port = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
      };

      forward = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      user = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
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
  ];

  options.kibadda = {
    hypr = lib.mkOption {
      type = hyprModule;
      default = {};
    };

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

    yubikey = lib.mkOption {
      type = yubikeyModule;
      default = {};
    };

    kitty = lib.mkOption {
      type = kittyModule;
      default = {};
    };

    font = lib.mkOption {
      type = fontModule;
      default = {};
    };

    ssh = lib.mkOption {
      type = lib.types.listOf sshModule;
      default = [];
    };
  };

  config = {
    home = {
      username = meta.username;

      homeDirectory = "/home/${meta.username}";

      packages = cfg.packages
        ++ (if cfg.browser == "chrome" then [ pkgs.google-chrome ] else [])
        ++ (if cfg.browser == "firefox" then [ pkgs.firefox ] else [])
        ++ [ pkgs.font-awesome cfg.font.pkg ];

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

    fonts.fontconfig.enable = true;

    xdg.enable = true;
  };
}
