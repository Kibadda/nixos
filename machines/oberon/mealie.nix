{
  meta,
  ...
}:
{
  oberon = {
    nginx."${meta.pi.mealie.domain}" = {
      restrict-access = true;
      port = 9000;
    };

    backup.mealie = {
      path = meta.pi.mealie.dir;
      time = "03:30";
    };
  };

  services.mealie.enable = true;
}
