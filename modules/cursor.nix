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
      sessionVariables = {
        XCURSOR_SIZE = cfg.cursor.size;
        HYPRCURSOR_SIZE = lib.mkIf cfg.hypr.enable cfg.cursor.size;
      };

      pointerCursor = cfg.cursor // {
        gtk.enable = true;
      };
    };

    wayland.windowManager.hyprland.exec-once = lib.mkIf cfg.hypr.enable [
      "hyprctl sercursor \"${cfg.cursor.name}\" ${toString cfg.cursor.size}"
    ];
  };
}
