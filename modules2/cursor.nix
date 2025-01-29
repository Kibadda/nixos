{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cursor;
in
{
  options = {
    cursor = {
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
      home = {
        pointerCursor = cfg // {
          gtk.enable = true;
        };
      };

      wayland.windowManager.hyprland.settings = lib.mkIf config.hyprland.enable {
        exec-once = [
          "hyprctl setcursor \"${cfg.name}\" ${toString cfg.size}"
        ];

        env = [
          "HYPRCURSOR_SIZE,${toString cfg.size}"
          "XCURSOR_SIZE,${toString cfg.size}"
        ];
      };
    };
  };
}
