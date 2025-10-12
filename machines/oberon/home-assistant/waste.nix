{
  secrets,
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
          entities = [
            {
              entity = "sensor.gelbe_tonne";
              name = "Gelbe Tonne";
            }
            {
              entity = "sensor.biotonne";
              name = "Biotonne";
            }
            {
              entity = "sensor.restmull";
              name = "Restmüll";
            }
            {
              entity = "sensor.papiertonne";
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
      template = [
        {
          sensor = [
            {
              name = "Gelbe Tonne";
              unique_id = "gelbe_tonne";
              state = ''
                {% set s0 = states("sensor.gelbe_tonne_0") | int %}
                {% set s1 = states("sensor.gelbe_tonne_1") | int %}
                {% set daysTo = min(s0, s1) %}
                {% if daysTo == 0 %}heute{% elif daysTo == 1%}morgen{% else %}in {{ daysTo }} Tagen{% endif %}
              '';
              icon = "mdi:recycle";
            }
            {
              name = "Biotonne";
              unique_id = "biotonne";
              state = ''
                {% set s0 = states("sensor.biotonne_0") | int %}
                {% set s1 = states("sensor.biotonne_1") | int %}
                {% set daysTo = min(s0, s1) %}
                {% if daysTo == 0 %}heute{% elif daysTo == 1%}morgen{% else %}in {{ daysTo }} Tagen{% endif %}
              '';
              icon = "mdi:leaf";
            }
            {
              name = "Papiertonne";
              unique_id = "papiertonne";
              state = ''
                {% set s0 = states("sensor.papiertonne_0") | int %}
                {% set s1 = states("sensor.papiertonne_1") | int %}
                {% set daysTo = min(s0, s1) %}
                {% if daysTo == 0 %}heute{% elif daysTo == 1%}morgen{% else %}in {{ daysTo }} Tagen{% endif %}
              '';
              icon = "mdi:package-variant";
            }
            {
              name = "Restmüll";
              unique_id = "restmull";
              state = ''
                {% set s0 = states("sensor.restmull_0") | int %}
                {% set s1 = states("sensor.restmull_1") | int %}
                {% set daysTo = min(s0, s1) %}
                {% if daysTo == 0 %}heute{% elif daysTo == 1%}morgen{% else %}in {{ daysTo }} Tagen{% endif %}
              '';
              icon = "mdi:trash-can";
            }
          ];
        }
      ];

      waste_collection_schedule = {
        sources = [
          {
            name = "jumomind_de";
            calendar_title = "Müll ${secrets.pi.home-assistant.street}";
            args = {
              service_id = "mymuell";
              city = secrets.pi.home-assistant.city;
              street = secrets.pi.home-assistant.street;
            };
          }
          {
            name = "jumomind_de";
            calendar_title = "Müll ${secrets.pi.home-assistant.street-other}";
            args = {
              service_id = "mymuell";
              city = secrets.pi.home-assistant.city;
              street = secrets.pi.home-assistant.street-other;
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
            value_template = "{{ value.daysTo }}";
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
            source_index = [
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
                  value_template = "{{ is_state('sensor.gelbe_tonne', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state('sensor.papiertonne', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state('sensor.restmull', 1) }}";
                }
                {
                  condition = "template";
                  value_template = "{{ is_state('sensor.biotonne', 1) }}";
                }
              ];
            }
          ];
          action = [
            {
              action = "notify.mobile_app_${secrets.pi.home-assistant.devices.michael}";
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
