{ lib, config, meta, ... }: let
  cfg = config.home-manager.users.${meta.username}.kibadda;
in {
  config = lib.mkIf cfg.hypr.enable {
    programs.hyprland.enable = true;

    security.pam.services.hyprlock = lib.mkIf cfg.yubikey.enable {
      u2fAuth = true;
    };
  };
}
