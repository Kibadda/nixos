{
  secrets,
  ...
}:
{
  flake.nixosModules.vaultwarden = {
    kibadda.services.vaultwarden = {
      description = "Tresor";
      subdomain = "pass";
      port = 8222;
      auth = "none";
      backup = {
        paths = [ "/var/lib/bitwarden_rs" ];
        time = "03:00";
      };
    };

    services.vaultwarden = {
      enable = true;
      environmentFile = "/etc/vaultwarden/env";
      config = {
        DOMAIN = "https://pass.${secrets.pi.domain}";
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
