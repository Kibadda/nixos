{
  meta,
  pkgs,
  ...
}:
{
  services = {
    nginx.virtualHosts."git.${meta.pi.domain}" = {
      # enableACME = true;
      # forceSSL = true;
      extraConfig = meta.pi.ip-whitelist;
      locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
    };

    gitlab = {
      enable = true;
      databasePasswordFile = pkgs.writeText "dbPassword" "asdfasdfasdf";
      initialRootPasswordFile = pkgs.writeText "rootPassword" "asdfasdfadf";
      secrets = {
        secretFile = pkgs.writeText "secret" "ASDFJKLS";
        otpFile = pkgs.writeText "otpsecret" "ASDFJKLS";
        dbFile = pkgs.writeText "dbsecret" "ASDFJKLS";
        jwsFile = pkgs.runCommand "oidcKeyBase" { } "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
      };
    };
  };
}
