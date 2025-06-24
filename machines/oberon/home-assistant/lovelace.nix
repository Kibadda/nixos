{
  lib,
  config,
  ...
}:
{
  options = {
    oberon.home-assistant.dashboard = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
      default = [ ];
    };
  };

  config = {
    services.home-assistant.lovelaceConfig = {
      title = "Home";
      icon = "mdi:home";
      views = [
        {
          title = "Home";
          max_columns = 3;
          sections = config.oberon.home-assistant.dashboard ++ [
            {
              cards = [
                {
                  type = "heading";
                  heading = "Misc";
                  heading_type = "title";
                  icon = "mdi:weather-partly-cloudy";
                }
                {
                  type = "weather-forecast";
                  entity = "weather.forecast_home";
                  forecast_type = "daily";
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
