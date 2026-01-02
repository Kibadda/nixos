{
  secrets,
  ...
}:
{
  oberon = {
    nginx.${secrets.pi.beszel.domain} = {
      restrict-access = true;
      websockets = true;
      port = 8090;
    };

    authelia.beszel = {
      secret = secrets.pi.authelia.oidc.beszel;
      redirect_uris = [
        "https://${secrets.pi.beszel.domain}/api/oauth2-redirect"
      ];
      auth_method = "basic";
    };

    dashboard.Home = [
      {
        name = "Beszel";
        icon = "beszel.svg";
        description = "Monitoring";
        url = "https://${secrets.pi.beszel.domain}";
      }
    ];
  };

  services.beszel = {
    hub = {
      enable = true;
      port = 8090;
      environment = {
        DISABLE_PASSWORD_AUTH = "true";
        USER_CREATION = "true";
        USER_EMAIL = secrets.pi.beszel.admin.email;
        USER_PASSWORD = secrets.pi.beszel.admin.password;
      };
    };

    agent = {
      enable = true;
      environment = {
        KEY = secrets.pi.beszel.oberon.key;
        TOKEN = secrets.pi.beszel.oberon.token;
        HUB_URL = "https://${secrets.pi.beszel.domain}";
        EXTRA_FILESYSTEMS = "sda1";
      };
    };
  };
}
