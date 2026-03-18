{
  lib,
  config,
  secrets,
  ...
}:
let
  cfg = config.home-manager.users.${secrets.base.username}.kibadda;
in
{
  config = lib.mkIf cfg.hypr.enable {
    programs.hyprland.enable = true;

    security.pam.services.hyprlock = lib.mkIf cfg.yubikey.enable {
      u2fAuth = true;
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "Hyprland";
          user = secrets.base.username;
        };
      };
    };
  };
}
