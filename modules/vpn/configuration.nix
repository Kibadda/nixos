{
  config,
  lib,
  secrets,
  ...
}:
let
  cfg = config.home-manager.users.${secrets.base.username}.kibadda;
in
{
  config = lib.mkIf cfg.vpn.enable {
    networking.wg-quick.interfaces.home = secrets.home.vpn;
  };
}
