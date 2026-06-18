{
  secrets,
  ...
}:
{
  flake.nixosModules.immich =
    {
      config,
      ...
    }:
    {
      kibadda.services.immich = {
        description = "Fotos";
        subdomain = "pics";
        port = 2283;
        open = true;
        extra = ''
          request_body {
            max_size 10GB
          }
        '';
        auth = "oidc";
        oidc = {
          redirect_uris = [
            "${config.kibadda.services.immich.url}/auth/login"
            "${config.kibadda.services.immich.url}/user-settings"
            "app.immich:///oauth-callback"
          ];
          method = "post";
        };
        backup = {
          archive = [ "/mnt/immich/backups" ];
          sync = [
            "/mnt/immich/library"
            "/mnt/immich/upload"
            "/mnt/immich/profile"
          ];
        };
        widget = {
          type = "immich";
          url = config.kibadda.services.immich.url;
          key = secrets.pi.immich.apikey;
          version = 2;
        };
        section = "Apps";
      };

      services.immich = {
        enable = true;
        machine-learning.enable = true;
        port = 2283;
        settings = {
          server.externalDomain = config.kibadda.services.immich.url;
          storageTemplate = {
            enabled = true;
            template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
          };
          oauth = {
            enabled = true;
            autoLaunch = true;
            issuerUrl = "${config.kibadda.services.authelia.url}/.well-known/openid-configuration";
            clientId = "immich";
            clientSecret = secrets.pi.authelia.oidc.immich;
          };
        };
        mediaLocation = "/mnt/immich";
      };

      systemd.tmpfiles.rules = [
        "d /mnt/immich 0750 immich immich - -"
        "x /mnt/immich"
      ];
    };
}
