{
  meta,
  pkgs,
  config,
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
      extraConfig = {
        gitlab = {
          default_theme = 11;
          time_zone = config.time.timeZone;
        };
      };
      extraGitlabRb = ''
        ApplicationSetting.last.update(signup_enabled: false)
        ApplicationSetting.last.update(first_day_of_week: 1)
      '';
      secrets = {
        secretFile = pkgs.writeText "secret" meta.pi.gitlab.secret;
        otpFile = pkgs.writeText "otpsecret" meta.pi.gitlab.otp;
        dbFile = pkgs.writeText "dbsecret" meta.pi.gitlab.db;
        jwsFile = pkgs.writeText "jwssecret" meta.pi.gitlab.jws;
      };
    };
  };
}
