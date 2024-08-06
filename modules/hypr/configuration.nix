{ lib, config, meta, pkgs, ... }: with lib; let
  cfg = config.home-manager.users.${meta.username}.kibadda;
in {
  programs.hyprland.enable = cfg.hypr.enable;

  environment = mkIf cfg.hypr.enable {
    systemPackages = with pkgs; [
      wl-clipboard
      grim
      slurp
    ];

    loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };
}
