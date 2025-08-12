{
  secrets,
  ...
}:
{
  oberon = {
    nginx."${secrets.pi.vaultwarden.domain}" = {
      restrict-access = true;
      port = 8222;
    };

    backup.vaultwarden = {
      path = secrets.pi.vaultwarden.dir;
      time = "02:00";
    };
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
