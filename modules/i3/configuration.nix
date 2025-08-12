{
  config,
  secrets,
  ...
}:
let
  cfg = config.home-manager.users.${secrets.base.username}.kibadda;
in
{
  services.xserver.windowManager.i3.enable = cfg.i3.enable;
}
