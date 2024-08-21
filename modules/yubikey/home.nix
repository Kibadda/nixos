{ config, meta, inputs, pkgs, lib, ... }: with lib; let
  cfg = config.kibadda;
in {
  config = mkIf cfg.yubikey.enable {
    home = {
      packages = if cfg.hypr.enable then [ inputs.pinentry.defaultPackage.${pkgs.system} ] else [];
      sessionVariables = {
        KEYID = meta.keyid;
      };
    };

    programs.gpg = {
      enable = true;
      scdaemonSettings.disable-ccid = true;

      publicKeys = [
        {
          source = ../../keys/gpg-0xBFA6A82102FF1B7A-2024-08-19.asc;
          trust = "ultimate";
        }
      ];
    };

    services = {
      dunst.settings.yubikey-touch-detector = mkIf cfg.yubikey.touch-detector {
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
