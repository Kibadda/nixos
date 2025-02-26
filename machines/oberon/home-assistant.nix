{
  meta,
  pkgs,
  ...
}:
{
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
      ];
      customComponents = [
        (pkgs.home-assistant-custom-components.waste_collection_schedule.overrideAttrs (
          final: _: {
            version = "2.6.0";
            src = pkgs.fetchFromGitHub {
              owner = "mampfes";
              repo = "hacs_waste_collection_schedule";
              tag = final.version;
              hash = "sha256-gfL5Nxe8io7DTya5x8aQ5PhxiH8rb8L3/CA+UqKEDAk=";
            };
          }
        ))
      ];
      configDir = meta.pi.home-assistant.dir;
      config = {
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

        waste_collection_schedule = {
          sources = [
            {
              name = "jumomind_de";
              args = {
                service_id = "mymuell";
                city = meta.pi.home-assistant.city;
                street = meta.pi.home-assistant.street;
              };
            }
          ];
        };

        sensor = [
          {
            platform = "waste_collection_schedule";
            name = "Blaue Tonne";
            value_template = "{% if value.daysTo == 0 %}heute{% elif value.daysTo == 1%}morgen{% else %}in {{ value.daysTo }} Tagen{% endif %}";
            date_template = "{{ value.date.strftime('%a, %d.%m.%Y') }}";
            types = [ "Blaue Tonne" ];
            add_days_to = true;
          }
          {
            platform = "waste_collection_schedule";
            name = "Gelber Sack";
            value_template = "{% if value.daysTo == 0 %}heute{% elif value.daysTo == 1%}morgen{% else %}in {{ value.daysTo }} Tagen{% endif %}";
            date_template = "{{ value.date.strftime('%a, %d.%m.%Y') }}";
            types = [ "Gelber Sack" ];
            add_days_to = true;
          }
          {
            platform = "waste_collection_schedule";
            name = "Biomüll";
            value_template = "{% if value.daysTo == 0 %}heute{% elif value.daysTo == 1%}morgen{% else %}in {{ value.daysTo }} Tagen{% endif %}";
            date_template = "{{ value.date.strftime('%a, %d.%m.%Y') }}";
            types = [ "Biomüll" ];
            add_days_to = true;
          }
          {
            platform = "waste_collection_schedule";
            name = "Restmüll";
            value_template = "{% if value.daysTo == 0 %}heute{% elif value.daysTo == 1%}morgen{% else %}in {{ value.daysTo }} Tagen{% endif %}";
            date_template = "{{ value.date.strftime('%a, %d.%m.%Y') }}";
            types = [ "Restmüll" ];
            add_days_to = true;
          }
        ];
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
