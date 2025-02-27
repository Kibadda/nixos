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
      title = "Dashboard";
      views = [
        {
          title = "Dashboard";
          cards = config.oberon.home-assistant.dashboard ++ [
            {
              entity = "weather.forecast_home";
              forecast_type = "daily";
              type = "weather-forecast";
            }
          ];
        }
      ];
    };
  };
}
