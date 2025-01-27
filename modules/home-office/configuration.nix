{
  lib,
  config,
  meta,
  ...
}:
let
  cfg = config.home-manager.users.${meta.username}.kibadda;
in
{
  config = lib.mkIf cfg.home-office.enable {
    networking.wg-quick.interfaces.work = meta.work.vpn;
  };
}
