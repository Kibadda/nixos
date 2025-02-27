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
              type = "entities";
              title = "Müll";
              entities = [
                {
                  entity = "sensor.gelber_sack";
                  name = "Gelber Sack";
                }
                {
                  entity = "sensor.biomull";
                  name = "Biomüll";
                }
                {
                  entity = "sensor.restmull";
                  name = "Restmüll";
                }
                {
                  entity = "sensor.blaue_tonne";
                  name = "Blaue Tonne";
                }
              ];
            }
            {
              entity = "weather.forecast_home";
              forecast_type = "daily";
              type = "weather-forecast";
            }
            {
              type = "tile";
              entity = "light.arbeitszimmer";
              name = "Arbeitszimmer";
              features = [
                { type = "light-brightness"; }
                { type = "light-color-temp"; }
              ];
            }
            {
              type = "tile";
              entity = "light.esszimmer";
              name = "Esszimmer";
              features = [
                { type = "light-brightness"; }
              ];
            }
            {
              type = "tile";
              entity = "light.wohnzimmer";
              name = "Wohnzimmer";
              features = [
                { type = "light-brightness"; }
                { type = "light-color-temp"; }
              ];
            }
          ];
        }
      ];
    };
  };
}
