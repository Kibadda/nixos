{
  secrets,
  pkgs,
  ...
}:
{
  oberon = {
    nginx.${secrets.pi.paperless.domain} = {
      restrict-access = true;
      port = 28981;
    };

    backup.paperless = {
      path = secrets.pi.paperless.dir;
      time = "04:00";
    };

    authelia.paperless = {
      secret = secrets.pi.authelia.oidc.paperless;
      redirect_uris = [
        "https://${secrets.pi.paperless.domain}/accounts/oidc/authelia/login/callback/"
      ];
    };

    dashboard.Home = [
      {
        name = "Paperless";
        icon = "paperless.svg";
        description = "Dokumente";
        url = "https://${secrets.pi.paperless.domain}";
      }
    ];
  };

  services.paperless = {
    enable = true;
    dataDir = secrets.pi.paperless.dir;
    database.createLocally = true;
    settings = {
      PAPERLESS_URL = "https://${secrets.pi.paperless.domain}";
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
      PAPERLESS_SOCIALACCOUNT_PROVIDERS = "{\"openid_connect\":{\"SCOPE\":[\"openid\",\"profile\",\"email\"],\"OAUTH_PKCE_ENABLED\":true,\"APPS\":[{\"provider_id\":\"authelia\",\"name\":\"Authelia\",\"client_id\":\"paperless\",\"secret\":\"${secrets.pi.authelia.oidc.paperless}\",\"settings\":{\"server_url\":\"https://${secrets.pi.authelia.domain}\",\"token_auth_method\":\"client_secret_basic\"}}]}}";
    };
    passwordFile = pkgs.writeText "dbPassword" secrets.pi.paperless.password;
  };
}
