{
  secrets,
  ...
}:
{
  services.home-assistant.config.automation = [
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
              {% set text = states('input_text.forgotten_things') %}
              {% if text is none %}
                - {{ trigger.event.data.args | join(' ') }}
              {% else %}
                {{ text + '\n- ' + trigger.event.data.args | join(' ') }}
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
