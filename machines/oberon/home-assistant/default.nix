{
  secrets,
  pkgs,
  ...
}:
{
  imports = [
    ./lovelace.nix
    ./waste.nix
    ./hue.nix
    ./automations.nix
  ];

  oberon = {
    nginx.${secrets.pi.home-assistant.domain} = {
      restrict-access = false;
      port = 8123;
      websockets = true;
    };

    backup.home-assistant = {
      path = secrets.pi.home-assistant.dir;
      time = "02:30";
    };

    dashboard.Coding = [
      {
        name = "Home Assistant";
        icon = "home-assistant.svg";
        description = "Smart Home";
        url = "https://${secrets.pi.home-assistant.domain}";
      }
    ];
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
      configDir = secrets.pi.home-assistant.dir;
      config = {
        mobile_app = { };

        recorder = {
          db_url = "postgresql://@/hass";
        };

        http = {
          server_port = 8123;
          base_url = "https://${secrets.pi.home-assistant.domain}";
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

        telegram_bot = [
          {
            platform = "polling";
            api_key = secrets.pi.home-assistant.telegram.bot_token;
            allowed_chat_ids = [ secrets.pi.home-assistant.telegram.chat_id ];
          }
        ];

        input_text = {
          forgotten_things = {
            name = "Vergessene Sachen";
            initial = "";
          };
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
