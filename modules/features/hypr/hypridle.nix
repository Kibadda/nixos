{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.hypr.hypridle = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf (cfg.hypr.enable && cfg.hypr.hypridle.enable) {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${pkgs.hypridle}/bin/hypridle"
    ];

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          before_sleep_cmd = "loginctl lock-session";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
