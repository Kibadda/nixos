{ config, lib, pkgs, ... }: let
  cfg = config.kibadda;
in {
  options = {
    kibadda.cursor = {
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

  config = {
    home = {
      pointerCursor = cfg.cursor // {
        gtk.enable = true;
      };
    };

    wayland.windowManager.hyprland.settings = lib.mkIf cfg.hypr.enable {
      exec-once = lib.mkIf cfg.hypr.enable [
        "hyprctl setcursor \"${cfg.cursor.name}\" ${toString cfg.cursor.size}"
      ];

      env = [
        "HYPRCURSOR_SIZE,${toString cfg.cursor.size}"
        "XCURSOR_SIZE,${toString cfg.cursor.size}"
      ];
    };
  };
}
