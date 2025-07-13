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

  # systemd.services = {
  #   state-uranus-on = {
  #     enable = true;
  #     description = "Update uranus state on startup";
  #     wantedBy = [ "multi-user.target" ];
  #     wants = [ "network-online.target" ];
  #     after = [ "network-online.target" ];
  #     serviceConfig = {
  #       Type = "oneshot";
  #       ExecStart = "${pkgs.curl}/bin/curl -X PUT https://${meta.pi.home-assistant.domain}/api/webhook/${meta.pi.home-assistant.webhooks.uranus.startup}";
  #     };
  #   };
  #
  #   state-uranus-off = {
  #     enable = true;
  #     description = "Update uranus state on shutdown";
  #     wantedBy = [ "shutdown.target" ];
  #     before = [ "shutdown.target" ];
  #     serviceConfig = {
  #       Type = "oneshot";
  #       ExecStart = "${pkgs.curl}/bin/curl -X PUT https://${meta.pi.home-assistant.domain}/api/webhook/${meta.pi.home-assistant.webhooks.uranus.shutdown}";
  #       TimeoutStartSec = 0;
  #       RemainAfterExit = "yes";
  #     };
  #   };
  # };
}
