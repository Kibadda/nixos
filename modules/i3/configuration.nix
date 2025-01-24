{ config, meta, ... }:
let
  cfg = config.home-manager.users.${meta.username}.kibadda;
in
{
  services.xserver.windowManager.i3.enable = cfg.i3.enable;
}
