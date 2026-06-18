{
  secrets,
  ...
}:
{
  flake.nixosModules.vaultwarden =
    {
      config,
      ...
    }:
    {
      kibadda.services.vaultwarden = {
        description = "Tresor";
        subdomain = "pass";
        port = 8222;
        auth = "none";
        backup.archive = [
          "/var/backup/vaultwarden"
        ];
        section = "Apps";
      };

      services.vaultwarden = {
        enable = true;
        environmentFile = "/etc/vaultwarden/env";
        backupDir = "/var/backup/vaultwarden";
        config = {
          DOMAIN = config.kibadda.services.vaultwarden.url;
          SIGNUPS_ALLOWED = false;
          SIGNUPS_VERIFY = false;
          INVITATIONS_ALLOWED = false;
          ROCKET_PORT = 8222;
        };
      };

      environment.etc = {
        "vaultwarden/env".text = secrets.pi.vaultwarden.environment;
      };
    };
}
