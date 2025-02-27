{
  meta,
  pkgs,
  ...
}:
{
  imports = [
    ./home-assistant/waste.nix
  ];

  oberon = {
    nginx."${meta.pi.home-assistant.domain}" = {
      port = 8123;
      websockets = true;
      restrict-access = true;
    };

    backup.home-assistant = {
      path = meta.pi.home-assistant.dir;
      time = "02:30";
    };
  };

  services = {
    home-assistant = {
      enable = true;
      package = pkgs.home-assistant.override {
        extraPackages = ps: [
          ps.psycopg2 # postgres support
        ];
      };
      extraComponents = [
        "sun"
        "google_translate"
        "met"
        "radio_browser"
        "isal"
        "hue"
        "esphome"
        "default_config"
        "frontend"
        "mobile_app"
      ];
      configDir = meta.pi.home-assistant.dir;
      config = {
        mobile_app = { };

        recorder = {
          db_url = "postgresql://@/hass";
        };

        http = {
          server_port = 8123;
          base_url = "https://${meta.pi.home-assistant.domain}";
          use_x_forwarded_for = true;
          cors_allowed_origins = "*";
          trusted_proxies = [
            "127.0.0.1"
            "::1"
          ];
        };

        homeassistant = {
          latitude = meta.pi.home-assistant.lat;
          longitude = meta.pi.home-assistant.lon;
          name = "Home";
          unit_system = "metric";
          country = "DE";
          language = "de";
        };
      };
      lovelaceConfig = {
        title = "Dashboard";
        views = [
          {
            title = "Dashboard";
            cards = [
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

    postgresql = {
      ensureDatabases = [ "hass" ];
      ensureUsers = [
        {
          name = "hass";
          ensureDBOwnership = true;
        }
      ];
    };
  };

  systemd.services.home-assistant = {
    serviceConfig = {
      PrivateDevices = true;
    };
  };
}
