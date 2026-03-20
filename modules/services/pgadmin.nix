{
  secrets,
  ...
}:
{
  flake.nixosModules.pgadmin =
    {
      pkgs,
      ...
    }:
    {
      kibadda.services.pgadmin = {
        description = "Datenbank";
        subdomain = "sql";
        port = 5050;
        auth = "oidc";
        oidc = {
          redirect_uris = [
            "https://sql.${secrets.pi.domain}/oauth2/authorize"
          ];
          method = "basic";
        };
      };

      services.pgadmin = {
        enable = true;
        port = 5050;
        initialEmail = secrets.base.email;
        initialPasswordFile = "/etc/pgadmin/pass";
        settings = {
          AUTHENTICATION_SOURCES = [ "oauth2" ];
          OAUTH2_AUTO_CREATE_USER = true;
          OAUTH2_CONFIG = [
            {
              OAUTH2_NAME = "authelia";
              OAUTH2_DISPLAY_NAME = "Authelia";
              OAUTH2_CLIENT_ID = "pgadmin";
              OAUTH2_CLIENT_SECRET = secrets.pi.authelia.oidc.pgadmin;
              OAUTH2_API_BASE_URL = "https://sso.${secrets.pi.domain}";
              OAUTH2_AUTHORIZATION_URL = "https://sso.${secrets.pi.domain}/api/oidc/authorization";
              OAUTH2_TOKEN_URL = "https://sso.${secrets.pi.domain}/api/oidc/token";
              OAUTH2_USERINFO_ENDPOINT = "https://sso.${secrets.pi.domain}/api/oidc/userinfo";
              OAUTH2_SERVER_METADATA_URL = "https://sso.${secrets.pi.domain}/.well-known/openid-configuration";
              OAUTH2_SCOPE = "openid email profile groups";
              OAUTH2_USERNAME_CLAIM = "email";
              OAUTH2_ICON = "fa-openid";
            }
          ];
        };
      };

      environment.etc = {
        "pgadmin/pass".text = secrets.pi.pgadmin.password;
      };
    };
}
