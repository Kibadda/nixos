{
  meta,
  pkgs,
  lib,
  ...
}:
{
  oberon = {
    nginx."${meta.pi.home-assistant.domain}" = {
      port = 8123;
      websockets = true;
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
        "isal"
        "hue"
        "esphome"
        "default_config"
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
        default_config = { };
        frontend = { };

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
        };

        waste_collection_schedult = {
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
            name = "Müll";
            value_template = "{{value.types|join(\", \")}}|{{value.daysTo}}|{{value.date.strftime(\"%d.%m.%Y\")}}|{{value.date.strftime(\"%a\")}}";
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
    reloadTriggers = lib.mkForce [ ];
  };
}
