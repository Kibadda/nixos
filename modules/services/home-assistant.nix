{
  lib,
  secrets,
  ...
}:
{
  flake.nixosModules.home-assistant =
    {
      config,
      pkgs,
      ...
    }:
    {
      kibadda.services.home-assistant = {
        description = "Home";
        subdomain = "home";
        port = 8123;
        open = true;
        auth = "none";
        section = "Apps";
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
            "esphome"
            "default_config"
            "frontend"
            "mobile_app"
            "hue"
            "telegram_bot"
            "local_calendar"
          ];
          customComponents = [
            pkgs.home-assistant-custom-components.waste_collection_schedule
          ];
          configDir = "/mnt/home-assistant";
          lovelaceConfig = {
            title = "Home";
            icon = "mdi:home";
            views = [
              {
                title = "Home";
                max_columns = 2;
                sections = [
                  {
                    cards = [
                      {
                        type = "heading";
                        heading = "Müll";
                        heading_style = "title";
                        icon = "mdi:recycle";
                      }
                      {
                        type = "entities";
                        entities = [
                          {
                            entity = "sensor.gelbe_tonne";
                            name = "Gelbe Tonne";
                          }
                          {
                            entity = "sensor.biotonne";
                            name = "Biotonne";
                          }
                          {
                            entity = "sensor.restmull";
                            name = "Restmüll";
                          }
                          {
                            entity = "sensor.papiertonne";
                            name = "Papiertonne";
                          }
                        ];
                      }
                    ];
                  }
                  {
                    cards = [
                      {
                        type = "heading";
                        heading = "Licht";
                        heading_style = "title";
                        icon = "mdi:lightbulb";
                      }
                      {
                        type = "tile";
                        entity = "light.flur";
                        name = "Flur";
                        features = [
                          { type = "light-brightness"; }
                        ];
                        grid_options.columns = "full";
                      }
                      {
                        type = "tile";
                        entity = "light.esszimmer";
                        name = "Esszimmer";
                        features = [
                          { type = "light-brightness"; }
                        ];
                        grid_options.columns = "full";
                      }
                    ];
                  }
                ];
              }
            ];
          };
          config = {
            mobile_app = { };

            recorder = {
              db_url = "postgresql://@/hass";
            };

            http = {
              server_port = 8123;
              use_x_forwarded_for = true;
              cors_allowed_origins = "*";
              trusted_proxies = [
                "127.0.0.1"
                "::1"
              ];
            };

            homeassistant = {
              latitude = secrets.pi.home-assistant.lat;
              longitude = secrets.pi.home-assistant.lon;
              name = "Home";
              unit_system = "metric";
              country = "DE";
              language = "de";
            };

            # telegram_bot = [
            #   {
            #     platform = "polling";
            #     api_key = secrets.pi.telegram.bot_token;
            #     allowed_chat_ids = [ secrets.pi.telegram.chat_id ];
            #   }
            # ];

            # hue.bridges = [
            #   {
            #     host = "10.0.0.22";
            #     allow_unreachable = true;
            #   }
            # ];

            waste_collection_schedule = {
              sources = [
                {
                  name = "jumomind_de";
                  args = {
                    service_id = "mymuell";
                    city = secrets.pi.home-assistant.city;
                    street = secrets.pi.home-assistant.street;
                  };
                }
              ];
              sensors =
                let
                  createSensor = type: {
                    name = type;
                    value_template = "{% if value.daysTo == 0 %}heute{% elif value.daysTo == 1%}morgen{% else %}in {{ value.daysTo }} Tagen{% endif %}";
                    types = [ type ];
                    add_days_to = true;
                  };
                in
                [
                  (createSensor "Biotonne")
                  (createSensor "Gelbe Tonne")
                  (createSensor "Restmüll")
                  (createSensor "Papiertonne")
                  {
                    name = "Müll";
                    value_template = "{{ value.types|join(', ') }}";
                  }
                ];
            };

            automation =
              map
                (
                  {
                    name,
                    trigger,
                    condition ? [ ],
                    title ? null,
                    message,
                  }:
                  {
                    alias = name;
                    mode = "single";
                    trigger = if lib.isList trigger then trigger else [ trigger ];
                    condition = if lib.isList condition then condition else [ condition ];
                    action = [
                      {
                        action = "notify.mobile_app_${secrets.pi.home-assistant.devices.michael}";
                        data = {
                          title = if title != null then title else name;
                          message = message;
                        };
                      }
                    ];
                  }
                )
                [
                  {
                    name = "Müll";
                    trigger = {
                      trigger = "time";
                      at = "18:00:00";
                    };
                    condition = {
                      or = [
                        {
                          condition = "template";
                          value_template = "{{ is_state('sensor.gelbe_tonne', 'morgen') }}";
                        }
                        {
                          condition = "template";
                          value_template = "{{ is_state('sensor.papiertonne', 'morgen') }}";
                        }
                        {
                          condition = "template";
                          value_template = "{{ is_state('sensor.restmull', 'morgen') }}";
                        }
                        {
                          condition = "template";
                          value_template = "{{ is_state('sensor.biotonne', 'morgen') }}";
                        }
                      ];
                    };
                    message = "{{ states('sensor.mull') }}";
                  }
                  {
                    name = "Geburtstag";
                    trigger = {
                      trigger = "calendar";
                      event = "start";
                      entity_id = "calendar.geburtstage";
                      offset = "09:00:00";
                    };
                    message = "{{ trigger.calendar_event.summary }} hat heute Geburtstag!";
                  }
                  {
                    name = "Handy laden";
                    trigger = [
                      {
                        trigger = "numeric_state";
                        entity_id = "sensor.${secrets.pi.home-assistant.devices.michael}_battery_level";
                        below = 21;
                      }
                      {
                        trigger = "numeric_state";
                        entity_id = "sensor.${secrets.pi.home-assistant.devices.michael}_battery_level";
                        below = 11;
                      }
                    ];
                    condition = [
                      {
                        condition = "state";
                        entity_id = "sensor.${secrets.pi.home-assistant.devices.michael}_battery_state";
                        state = "discharging";
                      }
                      {
                        condition = "state";
                        entity_id = "sensor.${secrets.pi.home-assistant.devices.michael}_wi_fi_connection";
                        state = [
                          secrets.home.wifi."2.4"
                          secrets.home.wifi."5.0"
                          secrets.work.wifi
                        ];
                      }
                    ];
                    title = ''
                      {% set level = states('sensor.${secrets.pi.home-assistant.devices.michael}_battery_level') | int %}
                      {% if level <= 10 %}!!! {% endif %}Akku Warnung{% if level <= 10 %} !!!{% endif %}
                    '';
                    message = "Dein Akku ist bei {{ states('sensor.${secrets.pi.home-assistant.devices.michael}_battery_level') }}%.";
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
    };
}
