{
  secrets,
  ...
}:
{
  oberon = {
    nginx."${secrets.pi.immich.domain}" = {
      restrict-access = false;
      port = 2283;
      websockets = true;
      extraConfig = ''
        client_max_body_size 100000M;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        send_timeout 600s;
      '';
    };

    backup.immich = {
      path = secrets.pi.immich.dir;
      time = "03:15";
    };

    authelia.immich = {
      secret = secrets.pi.authelia.oidc.immich;
      redirect_uris = [
        "https://${secrets.pi.immich.domain}/auth/login"
        "https://${secrets.pi.immich.domain}/user-settings"
        "app.immich:///oauth-callback"
      ];
      auth_method = "post";
    };
  };

  services.immich = {
    enable = true;
    openFirewall = true;
    machine-learning.enable = true;
    settings = {
      server.externalDomain = "https://${secrets.pi.immich.domain}";
      storageTemplate = {
        enabled = true;
        template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
      };
      oauth = {
        enabled = true;
        autoLaunch = true;
        issuerUrl = "https://${secrets.pi.authelia.domain}/.well-known/openid-configuration";
        clientId = "immich";
        clientSecret = secrets.pi.authelia.oidc.immich;
      };
    };
    mediaLocation = secrets.pi.immich.dir;
  };

  systemd.tmpfiles.rules = [
    "d ${secrets.pi.immich.dir} 0750 immich immich - -"
    "x ${secrets.pi.immich.dir}"
  ];
}
