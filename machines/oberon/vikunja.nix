{
  secrets,
  lib,
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
      files.basepath = lib.mkForce "${secrets.pi.vikunja.dir}/files";
    };
  };

  systemd.services.vikunja.serviceConfig = {
    User = "vikunja";
    Group = "vikunja";
    DynamicUser = lib.mkForce false;
  };

  users = {
    users.vikunja = {
      isSystemUser = true;
      group = "vikunja";
      home = secrets.pi.vikunja.dir;
      createHome = true;
    };

    groups.vikunja = { };
  };

  systemd.tmpfiles.rules = [
    "d ${secrets.pi.vikunja.dir} 0750 vikunja vikunja - -"
    "d ${secrets.pi.vikunja.dir}/files 0750 vikunja vikunja - -"
  ];
}
