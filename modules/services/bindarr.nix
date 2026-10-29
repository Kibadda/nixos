{
  secrets,
  self,
  ...
}:
{
  flake.nixosModules.bindarr =
    {
      config,
      ...
    }:
    {
      imports = [
        self.nixosModules.virtualisation
      ];

      kibadda.services.bindarr = {
        description = "MTG Collection";
        subdomain = "mtg";
        port = 6421;
        auth = "oidc";
        oidc = {
          redirect_uris = [
            "${config.kibadda.services.bindarr.url}/api/auth/oidc/callback"
          ];
          method = "basic";
        };
        icon = "https://raw.githubusercontent.com/thenotoriousJeremy/bindarr/b9c2c4ad4985c532ac00dfbf067e45b4c69b95a0/frontend/public/logo.svg";
        section = "Apps";
      };

      virtualisation.oci-containers.containers.bindarr = {
        image = "ghcr.io/thenotoriousjeremy/bindarr:1.8.8";
        ports = [ "127.0.0.1:6421:3001" ];
        environment = {
          TRUST_PROXY = "1";
          PUBLIC_BASE_URL = config.kibadda.services.bindarr.url;
          ALLOW_REGISTRATION = "false";
          OIDC_ENABLED = "true";
          OIDC_ISSUER_URL = config.kibadda.services.authelia.url;
          OIDC_CLIENT_ID = "bindarr";
          OIDC_CLIENT_SECRET = secrets.pi.authelia.oidc.bindarr;
          OIDC_PROVIDER_NAME = "Authelia";
        };
        volumes = [
          "/mnt/bindarr/data:/app/database"
        ];
      };

      systemd.tmpfiles.rules = [
        "d /mnt/bindarr 0755 root root -"
        "d /mnt/bindarr/data 0755 root root -"
      ];
    };
}
