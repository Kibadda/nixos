{
  config,
  meta,
  ...
}:
let
  cfg = config.home-manager.users.${meta.username}.kibadda;
in
{
  programs.steam.enable = cfg.gaming.steam;
}
