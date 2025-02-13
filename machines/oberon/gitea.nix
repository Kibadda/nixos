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
      extraConfig = meta.pi.ip-whitelist;
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
        service = {
          # on first installation this should be false
          # to create first admin account
          DISABLE_REGISTRATION = true;
          REQUIRE_SIGNIN_VIEW = true;
        };
      };
      database = {
        type = "postgres";
        passwordFile = pkgs.writeText "dbPassword" meta.pi.gitea.db-password;
      };
    };
  };
}
