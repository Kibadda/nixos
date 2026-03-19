{
  secrets,
  ...
}:
{
  flake.nixosModules.immich = {
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
          "https://pics.${secrets.pi.domain}/auth/login"
          "https://pics.${secrets.pi.domain}/user-settings"
          "app.immich:///oauth-callback"
        ];
        method = "post";
      };
      backup = {
        paths = [ "/mnt/immich" ];
        time = "03:15";
      };
    };

    services.immich = {
      enable = true;
      openFirewall = true;
      machine-learning.enable = true;
      settings = {
        server.externalDomain = "https://pics.${secrets.pi.domain}";
        storageTemplate = {
          enabled = true;
          template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
        };
        oauth = {
          enabled = true;
          autoLaunch = true;
          issuerUrl = "https://sso.${secrets.pi.domain}/.well-known/openid-configuration";
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
