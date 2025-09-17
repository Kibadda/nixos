{
  secrets,
  ...
}:
{
  oberon = {
    nginx.${secrets.pi.vaultwarden.domain} = {
      restrict-access = true;
      port = 8222;
    };

    backup.vaultwarden = {
      path = secrets.pi.vaultwarden.dir;
      time = "02:00";
    };

    dashboard.Coding = [
      {
        name = "Vaultwarden";
        icon = "vaultwarden.svg";
        description = "Passwörter";
        url = "https://${secrets.pi.vaultwarden.domain}";
      }
    ];
  };

  services.vaultwarden = {
    enable = true;
    environmentFile = "/etc/vaultwarden/env";
    config = {
      DOMAIN = "https://${secrets.pi.vaultwarden.domain}";
      SIGNUPS_ALLOWED = false;
      SIGNUPS_VERIFY = false;
      INVITATIONS_ALLOWED = false;
      ROCKET_PORT = 8222;
    };
  };

  environment.etc = {
    "vaultwarden/env".text = secrets.pi.vaultwarden.environment;
  };
}
