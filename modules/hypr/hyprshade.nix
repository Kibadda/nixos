{ pkgs, config, lib, ... }: let
  cfg = config.kibadda;
in {
  config = lib.mkIf cfg.hypr.enable {
    home = {
      packages = [
        pkgs.hyprshade
      ];

      file.".config/hypr/hyprshade.toml".text = ''
        [[shades]]
        name = "blue-light-filter"
        start_time = 19:00:00
        end_time = 07:00:00
      '';
    };

    wayland.windowManager.hyprland.settings = {
      bind = [
        "SUPER SHIFT, S, exec, ${pkgs.hyprshade}/bin/hyprshade toggle"
      ];

      exec = [
        "${pkgs.hyprshade}/bin/hyprshade auto"
      ];
    };
  };
}
