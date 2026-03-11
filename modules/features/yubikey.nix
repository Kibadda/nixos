{
  secrets,
  ...
}:
{
  flake.homeModules.yubikey =
    {
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
      environment.systemPackages = with pkgs; [
        gnupg
        yubikey-personalization
        yubikey-manager
      ];

      security.pam.services = {
        sudo.u2fAuth = true;
      };

      services = {
        udev.packages = [
          pkgs.yubikey-personalization
        ];
        pcscd.enable = true;
      };
    };
}
