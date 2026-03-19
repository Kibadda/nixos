{
  secrets,
  ...
}:
{
  flake.nixosModules.beszel-server = {
    kibadda.services.beszel = {
      description = "Monitoring";
      subdomain = "monitoring";
      port = 8090;
      auth = "oidc";
      oidc = {
        redirect_uris = [
          "https://monitoring.${secrets.pi.domain}/api/oauth2-redirect"
        ];
        method = "basic";
      };
    };

    services.beszel.hub = {
      enable = true;
      port = 8090;
      environment = {
        DISABLE_PASSWORD_AUTH = "true";
        USER_CREATION = "true";
        USER_EMAIL = secrets.pi.beszel.admin.email;
        USER_PASSWORD = secrets.pi.beszel.admin.password;
      };
    };
  };

  flake.nixosModules.beszel-client =
    {
      config,
      ...
    }:
    {
      services.beszel.agent = {
        enable = true;
        environment = {
          KEY = secrets.pi.beszel.${config.networking.hostName}.key;
          TOKEN = secrets.pi.beszel.${config.networking.hostName}.token;
          HUB_URL = "https://monitoring.${secrets.pi.domain}";
        };
      };
    };
}
