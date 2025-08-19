{
  secrets,
  ...
}:
{
  oberon = {
    nginx."${secrets.pi.vikunja.domain}" = {
      restrict-access = true;
      port = 3456;
    };

    backup.vikunja = {
      path = secrets.pi.vikunja.dir;
      time = "03:30";
    };
  };

  services.vikunja = {
    enable = true;
    frontendHostname = secrets.pi.vikunja.domain;
    frontendScheme = "https";
    database.path = "${secrets.pi.vikunja.dir}/vikunja.db";
    settings = {
      service.timezone = "CET";
      defaultsettings = {
        week_start = 1;
        language = "de";
      };
    };
  };
}
