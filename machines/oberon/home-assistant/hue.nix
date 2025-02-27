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
    config.hue.bridges = [
      {
        host = "10.0.0.22";
        allow_unreachable = true;
      }
    ];
  };
}
