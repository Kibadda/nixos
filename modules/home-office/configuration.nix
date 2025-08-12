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
  config = lib.mkIf cfg.home-office.enable {
    networking.wg-quick.interfaces.work = secrets.work.vpn;
  };
}
