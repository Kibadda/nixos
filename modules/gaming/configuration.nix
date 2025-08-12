{
  config,
  secrets,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home-manager.users.${secrets.base.username}.kibadda;
in
{
  programs.steam.enable = cfg.gaming.steam;

  environment.systemPackages = (lib.optional cfg.gaming.pinball [ pkgs.space-cadet-pinball ]) ++ [ ];
}
