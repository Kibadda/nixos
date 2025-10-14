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
            message = "Dein Akku ist bei {{ states('sensor.${secrets.pi.home-assistant.devices.michael}_battery_level' }}%.";
          };
        }
      ];
    }

    {
      alias = "Vergessene Sachen";
      mode = "single";
      trigger = [
        {
          trigger = "state";
          entity_id = "sensor.${secrets.pi.home-assistant.devices.michael}_wi_fi_connection";
          to = [
            secrets.home.wifi."5.0"
            secrets.home.wifi."2.4"
          ];
        }
      ];
      condition = [
        {
          condition = "template";
          value_template = "{% set text = states('input_text.forgotten_things') %}{{ text is not none and text != ''}}";
        }
      ];
      action = [
        {
          action = "telegram_bot.send_message";
          data = {
            title = "*Vergessene Sachen*";
            message = "{{ states('input_text.forgotten_things') }}";
          };
        }
        {
          action = "input_text.set_value";
          target = {
            entity_id = "input_text.forgotten_things";
          };
          data = {
            value = "";
          };
        }
      ];
    }

    {
      alias = "Neue vergessene Sache";
      mode = "single";
      trigger = [
        {
          trigger = "event";
          event_type = "telegram_command";
          event_data = {
            command = "/todo";
          };
        }
      ];
      action = [
        {
          action = "input_text.set_value";
          target = {
            entity_id = "input_text.forgotten_things";
          };
          data = {
            value = ''
              {% set current = states('input_text.forgotten_things') %}
              {% set text = trigger.event.data.args | join(' ') %}
              {% if current is none or current == "" %}
                - {{ text }}
              {% else %}
                {{ current + '\n- ' + text }}
              {% endif %}
            '';
          };
        }
        {
          action = "telegram_bot.delete_message";
          data = {
            message_id = "{{ trigger.event.data.id }}";
            chat_id = "{{ trigger.event.data.chat_id }}";
          };
        }
      ];
    }
  ];
}
