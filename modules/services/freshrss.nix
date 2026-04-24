{
  secrets,
  ...
}:
{
  flake.nixosModules.freshrss =
    {
      config,
      pkgs,
      ...
    }:
    {
      kibadda.services.freshrss = {
        description = "RSS";
        subdomain = "rss";
        auth = "forward";
        extra = ''
          root * ${config.services.freshrss.package}/p
          php_fastcgi unix/${config.services.phpfpm.pools.freshrss.socket} {
            env FRESHRSS_DATA_PATH ${config.services.freshrss.dataDir}
          }
          file_server
        '';
      };

      services = {
        freshrss = {
          enable = true;
          authType = "none";
          webserver = "caddy";
          virtualHost = "dummy.${secrets.pi.domain}";
          baseUrl = "https://rss.${secrets.pi.domain}";
          defaultUser = "admin";
          language = "de";
          dataDir = "/mnt/freshrss";
          database = {
            type = "pgsql";
            host = "/run/postgresql";
            port = null;
            user = "freshrss";
            name = "freshrss";
            passFile = null;
          };
          extensions = with pkgs.freshrss-extensions; [
            reddit-image
            youtube
          ];
        };

        postgresql = {
          ensureDatabases = [ "freshrss" ];
          ensureUsers = [
            {
              name = "freshrss";
              ensureDBOwnership = true;
            }
          ];
        };
      };
    };
}
