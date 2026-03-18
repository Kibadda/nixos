{
  config,
  secrets,
  ...
}:
let
  cfg = config.home-manager.users.${secrets.base.username}.kibadda;
in
{
  config = {
    networking.wg-quick.interfaces = cfg.vpn;
  };
}
