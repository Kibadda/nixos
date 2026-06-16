{
  secrets,
  ...
}:
{
  flake.nixosModules.mealie =
    {
      config,
      ...
    }:
    {
      kibadda.services.mealie = {
        description = "Essen";
        subdomain = "food";
        port = 9000;
        auth = "oidc";
        oidc = {
          redirect_uris = [
            "${config.kibadda.services.mealie.url}/login"
          ];
          method = "basic";
        };
        backup = {
          paths = [ "/var/lib/mealie" ];
          time = "03:45";
        };
        backup2.archive = [ "/var/lib/private/mealie" ];
        section = "Apps";
      };

      services.mealie = {
        enable = true;
        port = 9000;
        settings = {
          API_DOCS = "false";
          ALLOW_SIGNUP = "false";
          ALLOW_PASSWORD_LOGIN = "false";

          OIDC_AUTH_ENABLED = "true";
          OIDC_CONFIGURATION_URL = "${config.kibadda.services.authelia.url}/.well-known/openid-configuration";
          OIDC_CLIENT_ID = "mealie";
          OIDC_CLIENT_SECRET = secrets.pi.authelia.oidc.mealie;
          OIDC_USER_GROUP = "family";
          OIDC_ADMIN_GROUP = "admin";
          OIDC_AUTO_REDIRECT = "true";
          OIDC_PROVIDER_NAME = "Authelia";
        };
      };
    };
}
