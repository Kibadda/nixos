{
  config,
  lib,
  meta,
  ...
}:
let
  cfg = config.home-manager.users.${meta.username}.kibadda;
in
{
  config = lib.mkIf cfg.vpn.enable {
    networking.wg-quick.interfaces.home = meta.home.vpn;
  };
}
