{
  secrets,
  self,
  ...
}:
{
  flake.nixosModules.trek =
    {
      config,
      ...
    }:
    {
      imports = [
        self.nixosModules.virtualisation
      ];

      kibadda.services.trek = {
        description = "Urlaub";
        subdomain = "urlaub";
        port = 5926;
        auth = "oidc";
        oidc = {
          redirect_uris = [
            "${config.kibadda.services.trek.url}/api/auth/oidc/callback"
          ];
          method = "post";
        };
        backup.archive = [ "/mnt/trek/data/travel.db" ];
        icon = "mdi-plane";
        section = "Apps";
      };

      virtualisation.oci-containers.containers.trek = {
        image = "mauriceboe/trek:latest";
        ports = [ "127.0.0.1:5926:3000" ];
        environment = {
          ENCRYPTION_KEY = secrets.pi.trek.key;
          TZ = config.time.timeZone;
          DEFAULT_LANGUAGE = "de";
          APP_URL = config.kibadda.services.trek.url;
          OIDC_ISSUER = config.kibadda.services.authelia.url;
          OIDC_CLIENT_ID = "trek";
          OIDC_CLIENT_SECRET = secrets.pi.authelia.oidc.trek;
          OIDC_DISPLAY_NAME = "Authelia";
          OIDC_ONLY = "true";
        };
        volumes = [
          "/mnt/trek/data:/app/data"
          "/mnt/trek/uploads:/app/uploads"
        ];
      };

      systemd.tmpfiles.rules = [
        "d /mnt/trek 0755 root root -"
        "d /mnt/trek/data 0755 root root -"
        "d /mnt/trek/uploads 0755 root root -"
      ];
    };
}
