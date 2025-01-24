{
  config,
  meta,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.yubikey = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      touch-detector = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      pam = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "sudo"
          "login"
        ];
      };
    };
  };

  config = lib.mkIf cfg.yubikey.enable {
    home = {
      packages = if cfg.hypr.enable then [ inputs.pinentry.defaultPackage.${pkgs.system} ] else [ ];
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
      dunst.settings.yubikey-touch-detector = lib.mkIf cfg.yubikey.touch-detector {
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
        pinentryPackage =
          if cfg.hypr.enable then inputs.pinentry.defaultPackage.${pkgs.system} else pkgs.pinentry-qt;
      };
    };
  };
}
