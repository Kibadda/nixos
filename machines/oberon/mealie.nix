{
  meta,
  ...
}:
{
  services = {
    nginx.virtualHosts."${meta.pi.mealie.domain}" = {
      enableACME = true;
      forceSSL = true;
      extraConfig = meta.pi.ip-whitelist;
      locations."/".proxyPass = "http://localhost:9000";
    };

    mealie = {
      enable = true;
      settings.DATA_DIR = meta.pi.mealie.dir;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${meta.pi.mealie.dir} 0755 mealie mealie - -"
    "x ${meta.pi.mealie.dir}"
  ];
}
