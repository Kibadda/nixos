{
  secrets,
  ...
}:
{
  services.home-assistant.config = {
    input_text = {
      home_reminder = {
        name = "Homeerinnerungen";
        initial = "";
      };
      work_reminder = {
        name = "Arbeitserinnerungen";
        initial = "";
      };
    };

    automation =
      let
        mkReminderAutomation =
          {
            name,
            trigger,
            input_text,
            command,
          }:
          [
            {
              alias = "Neue ${name}";
              mode = "single";
              trigger = [
                {
                  trigger = "event";
                  event_type = "telegram_command";
                  event_data.command = command;
                }
              ];
              action = [
                {
                  action = "input_text.set_value";
                  target.entity_id = "input_text.${input_text}";
                  data.value = ''
                    {% set current = states('input_text.${input_text}') %}
                    {% set text = trigger.event.data.args | join(' ') %}
                    {% if current is none or current == "" %}
                      - {{ text }}
                    {% else %}
                      {{ current + '\n- ' + text }}
                    {% endif %}
                  '';
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

            {
              alias = name;
              mode = "single";
              trigger = [ trigger ];
              condition = [
                {
                  condition = "template";
                  value_template = "{% set text = states('input_text.${input_text}') %}{{ text is not none and text != '' }}";
                }
              ];
              action = [
                {
                  action = "telegram_bot.send_message";
                  data = {
                    title = "*${name}*";
                    message = "{{ states('input_text.${input_text}') }}";
                  };
                }
                {
                  action = "input_text.set_value";
                  target.entity_id = "input_text.${input_text}";
                  data.value = "";
                }
              ];
            }
          ];
      in
      (mkReminderAutomation {
        name = "Homeerinnerungen";
        input_text = "home_reminder";
        command = "/todo";
        trigger = {
          trigger = "state";
          entity_id = "sensor.${secrets.pi.home-assistant.devices.michael}_wi_fi_connection";
          to = [
            secrets.home.wifi."5.0"
            secrets.home.wifi."2.4"
          ];
        };
      })
      ++ (mkReminderAutomation {
        name = "Arbeitserinnerungen";
        input_text = "work_reminder";
        command = "/work";
        trigger = {
          platform = "time";
          at = "05:50:00";
        };
      })
      ++ [ ];
  };
}
