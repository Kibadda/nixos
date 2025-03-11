{
  meta,
  pkgs,
  ...
}:
{
  imports = [
    ../common/desktop.nix
    ../common/configuration.nix
    ../common/home.nix

    ../../modules/kibadda/configuration.nix
  ];

  systemd.services = {
    hue-arbeitszimmer-on = {
      description = "Turn on lights in arbeitszimmer";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.curl}/bin/curl -X PUT https://${meta.pi.home-assistant.domain}/api/webhook/${meta.pi.home-assistant.webhooks.uranus.light_on}";
      };
    };

    hue-arbeitszimmer-off = {
      description = "Turn off lights in arbeitszimmer";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "final.target"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.curl}/bin/curl -X PUT https://${meta.pi.home-assistant.domain}/api/webhook/${meta.pi.home-assistant.webhooks.uranus.light_off}";
      };
    };
  };
}
