{
  secrets,
  ...
}:
{
  oberon = {
    nginx."${secrets.pi.mealie.domain}" = {
      restrict-access = true;
      port = 9000;
    };

    backup.mealie = {
      path = secrets.pi.mealie.dir;
      time = "03:30";
    };

    authelia.mealie = {
      secret = secrets.pi.authelia.oidc.mealie;
      redirect_uris = [
        "https://${secrets.pi.mealie.domain}/login"
      ];
    };
  };

  services.mealie = {
    enable = true;
    settings = {
      ALLOW_PASSWORD_LOGIN = false;
      OIDC_AUTH_ENABLED = "true";
      OIDC_CONFIGURATION_URL = "https://${secrets.pi.authelia.domain}/.well-known/openid-configuration";
      OIDC_CLIENT_ID = "mealie";
      OIDC_CLIENT_SECRET = secrets.pi.authelia.oidc.mealie;
      OIDC_AUTO_REDIRECT = true;
      OIDC_PROVIDER_NAME = "Authelia";
    };
  };
}
