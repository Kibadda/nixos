{
  meta,
  pkgs,
  ...
}:
{
  services = {
    nginx.virtualHosts."${meta.pi.gitea.domain}" = {
      enableACME = true;
      forceSSL = true;
      # extraConfig = meta.pi.ip-whitelist;
      locations."/".proxyPass = "http://localhost:3000";
    };

    gitea = {
      enable = true;
      appName = "Personal Git";
      settings = {
        server = {
          DOMAIN = meta.pi.gitea.domain;
          ROOT_URL = "https://${meta.pi.gitea.domain}/";
        };
        service.DISABLE_REGISTRATION = true;
      };
      database = {
        type = "postgres";
        passwordFile = pkgs.writeText "dbPassword" meta.pi.gitea.db-password;
      };
      stateDir = meta.pi.gitea.dir;
    };
  };
}
