{ pkgs, config, meta, lib, ... }: let
  cfg = config.home-manager.users.${meta.username}.kibadda;
in {
  config = lib.mkIf cfg.yubikey.enable {
    programs.yubikey-touch-detector.enable = cfg.yubikey.touch-detector;

    environment.systemPackages = with pkgs; [
      gnupg
      yubikey-personalization
      yubikey-manager
    ];

    security.pam.services = builtins.listToAttrs (map (name: {
      name = name;
      value = { u2fAuth = true; };
    }) cfg.yubikey.pam);

    services = {
      udev.packages = with pkgs; [
        yubikey-personalization
      ];
      pcscd.enable = true;
    };
  };
}
