{
  secrets,
  ...
}:
{
  services.home-assistant.config.automation = [
    {
      alias = "Handy laden";
      mode = "single";
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
      action = [
        {
          action = "notify.mobile_app_${secrets.pi.home-assistant.devices.michael}";
          data = {
            title = ''
              {% set level = states('sensor.${secrets.pi.home-assistant.devices.michael}_battery_level') | int %}
              {% if level <= 10 %}!!! {% endif %}Akku Warnung{% if level <= 10 %} !!!{% endif %}
            '';
            message = "Dein Akku ist bei {{ states('sensor.${secrets.pi.home-assistant.devices.michael}_battery_level') }}%.";
          };
        }
      ];
    }
  ];
}
