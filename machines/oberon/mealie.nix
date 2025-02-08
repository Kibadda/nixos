{
  meta,
  ...
}:
{
  services = {
    nginx.virtualHosts."essen.${meta.pi.domain}" = {
      enableACME = true;
      forceSSL = true;
      extraConfig = meta.pi.ip-whitelist;
      locations."/".proxyPass = "http://localhost:9000";
    };

    mealie.enable = true;
  };
}
