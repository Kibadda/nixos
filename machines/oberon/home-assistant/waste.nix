{
  meta,
  pkgs,
  ...
}:
{
  oberon.home-assistant.dashboard = [
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
          title = meta.pi.home-assistant.street;
          entities = [
            {
              entity = "sensor.gelbe_tonne_0";
              name = "Gelbe Tonne";
            }
            {
              entity = "sensor.biotonne_0";
              name = "Biotonne";
            }
            {
              entity = "sensor.restmull_0";
              name = "Restmüll";
            }
            {
              entity = "sensor.papiertonne_0";
              name = "Papiertonne";
            }
          ];
        }
        {
          type = "entities";
          title = meta.pi.home-assistant.street-other;
          entities = [
            {
              entity = "sensor.gelbe_tonne_1";
              name = "Gelbe Tonne";
            }
            {
              entity = "sensor.biotonne_1";
              name = "Biotonne";
            }
            {
              entity = "sensor.restmull_1";
              name = "Restmüll";
            }
            {
              entity = "sensor.papiertonne_1";
              name = "Papiertonne";
            }
          ];
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
            calendar_title = "Müll ${meta.pi.home-assistant.street}";
            args = {
              service_id = "mymuell";
              city = meta.pi.home-assistant.city;
              street = meta.pi.home-assistant.street;
            };
          }
          {
            name = "jumomind_de";
            calendar_title = "Müll ${meta.pi.home-assistant.street-other}";
            args = {
              service_id = "mymuell";
              city = meta.pi.home-assistant.city;
              street = meta.pi.home-assistant.street-other;
            };
          }
        ];
      };

      sensor =
        let
          sensor = type: index: {
            platform = "waste_collection_schedule";
            source_index = index;
            name = "${type} ${toString index}";
            value_template = "{% if value.daysTo == 0 %}heute{% elif value.daysTo == 1%}morgen{% else %}in {{ value.daysTo }} Tagen{% endif %}";
            date_template = "{{ value.date.strftime('%a, %d.%m.%Y') }}";
            types = [ type ];
            add_days_to = true;
          };

          createSensor = type: [
            (sensor type 0)
            (sensor type 1)
          ];
        in
        (createSensor "Biotonne")
        ++ (createSensor "Gelbe Tonne")
        ++ (createSensor "Restmüll")
        ++ (createSensor "Papiertonne")
        ++ [
          {
            platform = "waste_collection_schedule";
            sensor_index = [
              0
              1
            ];
            name = "Müll";
            value_template = "{{ value.types|join(', ') }}";
          }
        ];

      automation = [
        {
          alias = "Müll";
          mode = "single";
          trigger = [
            {
              platform = "time";
              at = "18:00:00";
            }
          ];
          condition = [
            {
              or = [
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.gelbe_tonne_0', 'daysTo', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.papiertonne_0', 'daysTo', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.restmull_0', 'daysTo', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.biotonne_0', 'daysTo', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.gelbe_tonne_1', 'daysTo', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.papiertonne_1', 'daysTo', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.restmull_1', 'daysTo', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state_attr('sensor.biotonne_1', 'daysTo', 1) }}";
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
