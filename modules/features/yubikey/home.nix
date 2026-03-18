{
  config,
  secrets,
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
        ];
      };
    };
  };

  config = lib.mkIf cfg.yubikey.enable {
    home = {
      packages = [ pkgs.kibadda.pinentry-adw-wrapped ];
      sessionVariables = {
        KEYID = secrets.base.keyid;
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
        pinentry = {
          package =
            if cfg.gnome.enable then
              pkgs.pinentry-gnome3
            else
              (if cfg.hypr.enable then pkgs.kibadda.pinentry-adw-wrapped else pkgs.pinentry-qt);
          program = lib.mkIf cfg.hypr.enable "pinentry-adw-wrapped";
        };
      };
    };

    wayland.windowManager.hyprland.settings.exec-once =
      lib.mkIf (cfg.hypr.enable && cfg.yubikey.touch-detector)
        [
          "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector"
        ];
  };
}
