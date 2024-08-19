{ lib, config, meta, ... }: let
  cfg = config.home-manager.users.${meta.username}.kibadda;
in {
  config = lib.mkIf cfg.hypr.enable {
    programs.hyprland.enable = true;

    environment.loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';

    security.pam.services.hyprlock = lib.mkIf cfg.yubikey.enable {
      u2fAuth = true;
    };
  };
}
