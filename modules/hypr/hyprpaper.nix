{ pkgs, config, lib, ... }: let
  cfg = config.kibadda;
in {
  config = lib.mkIf cfg.hypr.enable {
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
