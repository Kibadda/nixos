{
  meta,
  ...
}:
{
  services = {
    nginx.virtualHosts."${meta.pi.immich.domain}" = {
      enableACME = true;
      forceSSL = true;
      # extraConfig = meta.pi.ip-whitelist;
      locations."/".proxyPass = "http://localhost:2283";
    };

    immich = {
      enable = true;
      openFirewall = true;
      machine-learning.enable = true;
      settings = {
        server.externalDomain = "https://${meta.pi.immich.domain}";
        storageTemplate = {
          enabled = true;
          template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
        };
      };
      mediaLocation = meta.pi.immich.dir;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${meta.pi.immich.dir} 0750 immich immich - -"
    "x ${meta.pi.immich.dir}"
  ];
}
