{
  config,
  secrets,
  lib,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.hypr.hyprlock = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };

  config = lib.mkIf (cfg.hypr.enable && cfg.hypr.hyprlock.enable) {
    programs.hyprlock = {
      enable = true;
      settings = {
        background = {
          monitor = "";
          path = "/home/${secrets.base.username}/.config/hypr/wallpaper.png";
          blur_passes = 3;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancy_darkness = 0.0;
        };

        general.grace = 5;

        input-field = {
          monitor = "";
          size = "280, 80";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "rgba(0, 0, 0, 0)";
          inner_color = "rgba(0, 0, 0, 0.5)";
          font_color = "rgb(200, 200, 200)";
          fade_on_empty = false;
          placeholder_text = "Password...";
          hide_input = false;
          position = "0, -120";
          halign = "center";
          valign = "center";
        };

        label = [
          {
            monitor = "";
            text = "cmd[update:1000] echo \"$(date +\"%-H:%M\")\"";
            font_size = 120;
            font_family = "${cfg.font.main.name} Nerd Font";
            position = "0, -300";
            halign = "center";
            valign = "top";
          }
          {
            monitor = "";
            text = "Hi there, ${secrets.base.name}";
            font_size = 25;
            font_family = "${cfg.font.main.name} Nerd Font";
            position = "0, -40";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
