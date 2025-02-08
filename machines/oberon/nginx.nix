{
  meta,
  ...
}:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = meta.email;
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
  };
}
