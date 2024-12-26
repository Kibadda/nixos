{ config, lib, ... }: let
  cfg = config.kibadda;
in {
  config = lib.mkIf (cfg.hypr.enable || cfg.i3.enable) {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          notification_limit = 5;
          frame_width = 1;
          frame_color = "#7F3FBF";
          separator_color = "auto";
          idle_threshhold = 0;
          font = "${cfg.font.name} Nerd Font 11";
          show_indicators = "no";
          sticky_history = false;
          history_length = 0;
          corner_radius = 7;
        };

        urgency_low = {
          background = "#28143C";
          foreground = "#FFFFFF";
          timeout = 5;
        };

        urgency_normal = {
          background = "#28143C";
          foreground = "#FFFFFF";
          timeout = 5;
        };

        urgency_critical = {
          background = "#28143C";
          foreground = "#FFFFFF";
          frame_color = "#FF7F7F";
          timeout = 120;
        };
      };
    };
  };
}
