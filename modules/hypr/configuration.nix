{ lib, config, meta, pkgs, ... }: with lib; let
  cfg = config.home-manager.users.${meta.username}.kibadda;
in {
  programs.hyprland.enable = cfg.hypr.enable;

  environment.loginShellInit = mkIf cfg.hypr.enable ''
    if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec Hyprland
    fi
  '';

  services.pam.services.hyprlock = mkIf cfg.yubikey.enable {
    u2fAuth = true;
  };
}
