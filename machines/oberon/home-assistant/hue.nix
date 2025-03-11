{
  meta,
  ...
}:
{
  oberon.home-assistant.dashboard = [
    {
      type = "tile";
      entity = "light.arbeitszimmer";
      name = "Arbeitszimmer";
      features = [
        { type = "light-brightness"; }
        { type = "light-color-temp"; }
      ];
    }
    {
      type = "tile";
      entity = "light.esszimmer";
      name = "Esszimmer";
      features = [
        { type = "light-brightness"; }
      ];
    }
    {
      type = "tile";
      entity = "light.wohnzimmer";
      name = "Wohnzimmer";
      features = [
        { type = "light-brightness"; }
        { type = "light-color-temp"; }
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
            trigger = "webhook";
            webhook_id = meta.pi.home-assistant.webhooks.uranus.light_on;
            allowed_methods = [ "PUT" ];
            local_only = false;
          }
        ];
        condition = [
          {
            condition = "time";
            before = "10:00:00";
            after = "21:00:00";
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
            trigger = "webhook";
            webhook_id = meta.pi.home-assistant.webhooks.uranus.light_off;
            allowed_methods = [ "PUT" ];
            local_only = false;
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
            offset = "02:00:00";
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
