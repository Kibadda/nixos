{
  inputs,
  secrets,
  ...
}:
{
  flake.nixosModules.homepage =
    {
      config,
      ...
    }:
    {
      imports = [ inputs.homepage.nixosModules.default ];

      kibadda.services.homepage = {
        description = "Homepage";
        subdomain = "h";
        open = true;
        auth = "oidc";
        oidc = {
          redirect_uris = [
            "${config.kibadda.services.homepage.url}/auth/callback"
          ];
          method = "post";
        };
        extra = ''
          root * /mnt/homepage/public
          php_fastcgi unix/${config.services.phpfpm.pools.homepage.socket}
          file_server
        '';
        icon = "${config.kibadda.services.homepage.url}/logo.svg";
        section = "Apps";
      };

      users.users.caddy.extraGroups = [ "homepage" ];

      services.homepage = {
        enable = true;
        appDir = "/mnt/homepage";
        environment = {
          APP_NAME = "Home";
          APP_ENV = "production";
          APP_DEBUG = "false";
          APP_URL = config.kibadda.services.homepage.url;
          APP_KEY = secrets.pi.homepage.key;
          AUTHELIA_BASE_URL = config.kibadda.services.authelia.url;
          AUTHELIA_CLIENT_ID = "homepage";
          AUTHELIA_CLIENT_SECRET = secrets.pi.authelia.oidc.homepage;
          NTFY_BASE_URL = config.kibadda.services.ntfy.url;
          NTFY_TOKEN = secrets.pi.homepage.ntfyToken;
          NTFY_TOPIC = "reminders";
        };
        composerAuth = secrets.pi.homepage.composer;
        deployKey = secrets.pi.homepage.sshKey;
      };
    };
}
