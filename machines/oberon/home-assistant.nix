{
  meta,
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

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      "isal"
      "hue"
      "esphome"
      "default_config"
      "wled"
    ];
    configDir = meta.pi.home-assistant.dir;
    config = {
      default_config = { };
      http = {
        server_port = 8123;
        base_url = "https://${meta.pi.home-assistant.domain}";
        use_x_forwarded_for = true;
        cors_allowed_origins = "*";
        trusted_proxies = [
          "127.0.0.1"
        ];
      };
      homeassistant = {
        latitude = meta.pi.home-assistant.lat;
        longitude = meta.pi.home-assistant.lon;
        name = "Home";
        unit_system = "metric";
      };
    };
  };
}
