{
  secrets,
  ...
}:
{
  flake.homeModules.yubikey =
    {
      lib,
      pkgs,
      ...
    }:
    {
      home.sessionVariables = {
        KEYID = secrets.base.keyid;
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

      services.gpg-agent = {
        enable = true;
        enableExtraSocket = true;
        enableSshSupport = true;
        defaultCacheTtl = 60;
        maxCacheTtl = 120;
        pinentry.package = pkgs.pinentry-gnome3;
      };
    };

  flake.nixosModules.yubikey =
    {
      pkgs,
      ...
    }:
    {
      environment = {
        systemPackages = with pkgs; [
          gnupg
          yubikey-personalization
          yubikey-manager
          pam_u2f
        ];

        etc."u2f_keys" = {
          text = secrets.base.u2f_keys;
          mode = "0444";
        };
      };

      programs.yubikey-touch-detector.enable = true;

      security.pam = {
        u2f.settings = {
          cue = true;
          cue_prompt = "🔑 DRÜCKEN 🔑";
          origin = "pam://kibadda";
          appid = "pam://kibadda";
          authfile = "/etc/u2f_keys";
        };
        services = {
          sudo.u2fAuth = true;
        };
      };

      services = {
        udev.packages = [
          pkgs.yubikey-personalization
        ];
        pcscd.enable = true;
      };
    };
}
