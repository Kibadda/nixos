{
  meta,
  pkgs,
  ...
}:
{
  services = {
    nginx.virtualHosts."git.${meta.pi.domain}" = {
      enableACME = true;
      forceSSL = true;
      extraConfig = meta.pi.ip-whitelist;
      locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
    };

    gitlab = {
      enable = true;
      initialRootEmail = meta.pi.gitlab.admin.username;
      initialRootPasswordFile = pkgs.writeText "rootPassword" meta.pi.gitlab.admin.password;
      databasePasswordFile = pkgs.writeText "dbPassword" meta.pi.gitlab.db-password;
      secrets = {
        secretFile = pkgs.writeText "secret" meta.pi.gitlab.secret;
        otpFile = pkgs.writeText "otpsecret" meta.pi.gitlab.otp;
        dbFile = pkgs.writeText "dbsecret" meta.pi.gitlab.db;
        jwsFile = pkgs.writeText "jwssecret" meta.pi.gitlab.jws;
      };
    };
  };
}
