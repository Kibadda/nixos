{
  oberon.home-assistant.dashboard = [
    {
      cards = [
        {
          type = "heading";
          heading = "Licht";
          heading_style = "title";
          icon = "mdi:lightbulb";
        }
        {
          type = "tile";
          entity = "light.arbeitszimmer";
          name = "Arbeitszimmer";
          features = [
            { type = "light-brightness"; }
            { type = "light-color-temp"; }
          ];
          grid_options.columns = "full";
        }
        {
          type = "tile";
          entity = "light.wohnzimmer";
          name = "Wohnzimmer";
          features = [
            { type = "light-brightness"; }
            { type = "light-color-temp"; }
          ];
          grid_options.columns = "full";
        }
        {
          type = "tile";
          entity = "light.esszimmer";
          name = "Esszimmer";
          features = [
            { type = "light-brightness"; }
          ];
          grid_options.columns = "full";
        }
      ];
    }
  ];

  services.home-assistant = {
    extraComponents = [ "hue" ];

    config.automation = [
      {
        alias = "Turn on lights after uranus start";
        trigger = [
          {
            trigger = "state";
            entity_id = "input_boolean.state_uranus";
            to = "on";
          }
        ];
        condition = [
          {
            condition = "time";
            after = "21:00:00";
            before = "10:00:00";
          }
        ];
        action = [
          {
            action = "light.turn_on";
            target = {
              entity_id = "light.arbeitszimmer";
            };
          }
        ];
      }
      {
        alias = "Turn off lights after uranus shutdown";
        trigger = [
          {
            trigger = "state";
            entity_id = "input_boolean.state_uranus";
            to = "off";
            for = {
              minutes = 1;
              seconds = 30;
            };
          }
        ];
        condition = [
          {
            condition = "time";
            after = "21:00:00";
            before = "04:00:00";
          }
        ];
        action = [
          {
            action = "light.turn_off";
            target = {
              entity_id = "light.arbeitszimmer";
            };
          }
        ];
      }
      {
        alias = "Turn off lights after sunrise";
        trigger = [
          {
            trigger = "sun";
            event = "sunrise";
            offset = "02:30:00";
          }
        ];
        condition = [
          {
            condition = "state";
            entity_id = "input_boolean.state_uranus";
            state = "on";
          }
        ];
        action = [
          {
            action = "light.turn_off";
            target = {
              entity_id = "light.arbeitszimmer";
            };
          }
        ];
      }
    ];

    # FIX: unfortunately this can not be done this way
    # config.hue.bridges = [
    #   {
    #     host = "10.0.0.22";
    #     allow_unreachable = true;
    #   }
    # ];
  };
}
