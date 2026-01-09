{
  lib,
  config,
  secrets,
  ...
}:
let
  cfg = config.home-manager.users.${secrets.base.username}.kibadda;
in
{
  config = lib.mkIf cfg.office.enable {
    networking.wg-quick.interfaces.work = lib.mkIf cfg.office.atHome secrets.work.vpn;

    security.pki.certificates = [ secrets.work.certificate ];
  };
}
