{
  meta,
  ...
}:
{
  services = {
    nginx.virtualHosts."essen.${meta.pi.domain}" = {
      enableACME = true;
      forceSSL = true;
      basicAuth = meta.pi.users;
      locations."/".proxyPass = "http://localhost:9000";
    };

    mealie.enable = true;
  };
}
