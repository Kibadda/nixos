{
  secrets,
  ...
}:
{
  flake.nixosModules.paperless =
    {
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
            "https://docs.${secrets.pi.domain}/accounts/oidc/authelia/login/callback/"
          ];
          method = "basic";
        };
        backup = {
          paths = [ "/mnt/paperless" ];
          time = "04:00";
        };
      };

      services.paperless = {
        enable = true;
        dataDir = "/mnt/paperless";
        database.createLocally = true;
        settings = {
          PAPERLESS_URL = "https://docs.${secrets.pi.domain}";
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
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
                    server_url = "https://sso.${secrets.pi.domain}";
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
