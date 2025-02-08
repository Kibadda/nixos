{
  meta,
  ...
}:
{
  services = {
    nginx.virtualHosts."fotos.${meta.pi.domain}" = {
      enableACME = true;
      forceSSL = true;
      basicAuth = meta.pi.users;
      locations."/".proxyPass = "http://localhost:2283";
    };

    immich = {
      enable = true;
      openFirewall = true;
      # FIX: tests for this are failing
      machine-learning.enable = false;
      settings = {
        server.externalDomain = "https://fotos.${meta.pi.domain}";
        storageTemplate = {
          enabled = true;
          template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
        };
      };
    };
  };
}
