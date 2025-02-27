{
  meta,
  pkgs,
  ...
}:
{
  oberon.home-assistant.dashboard = [
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
  ];

  services.home-assistant = {
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

    config = {
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
        {
          platform = "waste_collection_schedule";
          name = "Müll";
          value_template = "{{ value.types|join(', ')}}";
        }
      ];

      automation = [
        {
          alias = "Müll";
          mode = "single";
          trigger = [
            {
              platform = "time";
              at = "19:00:00";
            }
          ];
          condition = [
            {
              or = [
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.gelber_sack', 'daysTo', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.blaue_tonne', 'daysTo', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.restmull', 'daysTo', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.biomull', 'daysTo', 1) }}";
                }
              ];
            }
          ];
          action = [
            {
              action = "notify.mobile_app_${meta.pi.home-assistant.devices.michael}";
              data = {
                title = "Müll";
                message = "{{ states('sensor.mull') }}";
              };
            }
          ];
        }
      ];
    };
  };
}
