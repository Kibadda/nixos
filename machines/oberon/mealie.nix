{
  meta,
  ...
}:
{
  oberon.nginx."${meta.pi.mealie.domain}" = {
    restrict-access = true;
    port = 9000;
  };

  services.mealie.enable = true;
}
