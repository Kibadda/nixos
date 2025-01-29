{
  lib,
  config,
  meta,
  pkgs,
  ...
}:
let
  cfg = config.yubikey;
in
{
  options = {
    yubikey = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      touch-detector = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };

      pam = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "ssh"
          "login"
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      home.sessionVariables = {
        KEYID = meta.keyid;
      };

      programs.gpg = {
        enable = true;
        scdaemonSettings.disable-ccid = true;
        publicKeys = [
          {
            source = ../keys/gpg-0xBFA6A82102FF1B7A-2024-08-19.asc;
            trust = "ultimate";
          }
        ];
      };

      services = {
        dunst.settings.yubikey-touch-detector = lib.mkIf cfg.touch-detector.enable {
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
          pinentryPackage = if config.hyprland.enable then pkgs.kibadda.pinentry else pkgs.pinentry-qt;
        };
      };
    };

    programs.yubikey-touch-detector.enable = cfg.touch-detector.enable;

    environment.systemPackages = with pkgs; [
      gnupg
      yubikey-personalization
      yubikey-manager
      kibadda.pinentry
    ];

    security.pam.services = builtins.listToAttrs (
      map (name: {
        inherit name;
        value = {
          u2fAuth = true;
        };
      }) cfg.pam
    );

    services = {
      udev.packages = with pkgs; [ yubikey-personalization ];
      pcscd.enable = true;
    };
  };
}
