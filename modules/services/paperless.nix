{
  secrets,
  ...
}:
{
  flake.nixosModules.paperless =
    {
      config,
      pkgs,
      ...
    }:
    {
      kibadda.services.paperless = {
        description = "Dokumente";
        subdomain = "docs";
        port = 28981;
        auth = "oidc";
        oidc = {
          redirect_uris = [
            "${config.kibadda.services.paperless.url}/accounts/oidc/authelia/login/callback/"
          ];
          method = "basic";
        };
        section = "Tools";
      };

      services.paperless = {
        enable = true;
        dataDir = "/mnt/paperless";
        settings = {
          PAPERLESS_URL = config.kibadda.services.paperless.url;
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_DISABLE_REGULAR_LOGIN = true;
          PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
          PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
          PAPERLESS_SOCIALACCOUNT_PROVIDERS = builtins.toJSON {
            openid_connect = {
              SCOPE = [
                "openid"
                "profile"
                "email"
              ];
              OAUTH_PKCE_ENABLED = true;
              APPS = [
                {
                  provider_id = "authelia";
                  name = "Authelia";
                  client_id = "paperless";
                  secret = secrets.pi.authelia.oidc.paperless;
                  settings = {
                    server_url = config.kibadda.services.authelia.domain;
                    token_auth_method = "client_secret_basic";
                  };
                }
              ];
            };
          };
        };
        passwordFile = pkgs.writeText "dbPassword" secrets.pi.paperless.password;
      };
    };
}
