{ lib, config, meta, inputs, pkgs, ... }: let
  cfg = config.kibadda;
in {
  programs = {
    yubikey-touch-detector.enable = true;
    ssh.startAgent = true;
  };

  security.pam.services = {
    sudo.u2fAuth = true;
    login.u2fAuth = true;
  };

  environment.systemPackages = with pkgs; [
    gnupg
    yubikey-personalization
  ];

  services = {
    udev.packages = with pkgs; [
      yubikey-personalization
    ];
    pcscd.enable = true;
  };

  home-manager.users.${meta.username} = {
    home = {
      packages = lib.concatLists [
        (lib.optional cfg.hypr.enable inputs.pinentry.defaultPackage.${pkgs.system})
      ];

      sessionVariables = {
        KEYID = meta.keyid;
      };
    };

    programs.gpg.enable = true;

    services = {
      dunst.settings.yubikey-touch-detector = {
        appname = "yubikey-touch-detector";
        skip_display = true;
        skip_history = true;
      };

      gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
        defaultCacheTtl = 60;
        maxCacheTtl = 120;
        pinentryPackage = (if cfg.hypr.enable then inputs.pinentry.defaultPackage.${pkgs.system} else pkgs.pinentry-qt);
      };
    };
  };
}
