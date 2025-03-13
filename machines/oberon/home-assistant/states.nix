{
  meta,
  ...
}:
{
  services.home-assistant.config = {
    input_boolean = {
      state_uranus = {
        name = "uranus state";
      };
    };

    automation = [
      {
        alias = "Update uranus state on startup";
        trigger = [
          {
            trigger = "webhook";
            webhook_id = meta.pi.home-assistant.webhooks.uranus.startup;
            allowed_methods = [ "PUT" ];
            local_only = false;
          }
        ];
        action = [
          {
            action = "input_boolean.turn_on";
            target = {
              entity_id = "input_boolean.state_uranus";
            };
          }
        ];
      }
      {
        alias = "Update uranus state on shutdown";
        trigger = [
          {
            trigger = "webhook";
            webhook_id = meta.pi.home-assistant.webhooks.uranus.shutdown;
            allowed_methods = [ "PUT" ];
            local_only = false;
          }
        ];
        action = [
          {
            action = "input_boolean.turn_off";
            target = {
              entity_id = "input_boolean.state_uranus";
            };
          }
        ];
      }
    ];
  };
}
