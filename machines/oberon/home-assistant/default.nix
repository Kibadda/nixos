{
  meta,
  pkgs,
  ...
}:
{
  imports = [
    ./lovelace.nix
    ./waste.nix
    ./hue.nix
    ./states.nix
  ];

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
        "radio_browser"
        "isal"
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
