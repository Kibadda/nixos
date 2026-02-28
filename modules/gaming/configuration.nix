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
  programs = lib.mkIf cfg.gaming.steam {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
    };

    gamemode.enable = true;
  };

  environment.systemPackages =
    (lib.optional cfg.gaming.pinball pkgs.space-cadet-pinball)
    ++ (lib.optional cfg.gaming.steam pkgs.mangohud)
    ++ [ ];
}
