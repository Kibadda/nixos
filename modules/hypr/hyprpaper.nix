{ pkgs, config, lib, ... }: let
  cfg = config.kibadda;
in {
  options = {
    kibadda.hypr.hyprpaper = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf (cfg.hypr.enable && cfg.hypr.hyprpaper.enable) {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${pkgs.hyprpaper}/bin/hyprpaper"
    ];

    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [ "~/.config/hypr/wallpaper.png" ];
        wallpaper = [ ",~/.config/hypr/wallpaper.png" ];
      };
    };
  };
}
