{ lib, pkgs, config, meta, ... }: with lib; let
  cfg = config.kibadda;

  cursorModule = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
      };

      package = mkOption {
        type = types.package;
      };

      size = mkOption {
        type = types.int;
        default = 24;
      };
    };
  };

  waybarModule = types.submodule {
    options = {
      battery = mkOption {
        type = types.bool;
        default = false;
      };

      backlight = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  hyprModule = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      settings = mkOption {
        type = types.attrsOf types.anything;
        default = {};
      };

      cursor = mkOption {
        type = types.nullOr cursorModule;
        default = null;
      };

      waybar = mkOption {
        type = waybarModule;
        default = {};
      };
    };
  };

  i3Module = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  gitModule = types.submodule {
    options = {
      email = mkOption {
        type = types.str;
        default = meta.email;
      };

      extraConfig = mkOption {
        type = types.attrsOf types.anything;
        default = {};
      };
    };
  };

  neovimModule = types.submodule {
    options = {
      dir = mkOption {
        type = types.str;
        default = "$HOME/Projects/neovim";
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
    ../neovim.nix
    ../kitty.nix
    ../dunst.nix
    ../eza.nix
  ];

  options.kibadda = {
    hypr = mkOption {
      type = hyprModule;
      default = {};
    };

    i3 = mkOption {
      type = i3Module;
      default = {};
    };

    wallpaper = mkOption {
      type = types.path;
      default = ../../wallpapers/forest.png;
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = [];
    };

    browser = mkOption {
      type = types.enum [ "chrome" "firefox" ];
      default = "chrome";
    };

    git = mkOption {
      type = gitModule;
      default = {};
    };

    neovim = mkOption {
      type = neovimModule;
      default = {};
    };
  };

  config = {
    warnings = if (!cfg.hypr.enable && !cfg.i3.enable) then [
      "there is no window manager configured for '${meta.hostname}'"
    ] else [];

    home = {
      username = meta.username;

      homeDirectory = "/home/${meta.username}";

      packages = cfg.packages ++ [ (if cfg.browser == "chrome" then pkgs.google-chrome else pkgs.firefox) ];

      sessionVariables = {
        BROWSER = (if cfg.browser == "chrome" then "google-chrome-stable" else "firefox");
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    xdg.enable = true;
  };
}
