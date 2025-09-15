{
  secrets,
  lib,
  ...
}:
{
  oberon = {
    nginx."${secrets.pi.vikunja.domain}" = {
      restrict-access = false;
      port = 3456;
    };

    backup.vikunja = {
      path = secrets.pi.vikunja.dir;
      time = "03:30";
    };

    authelia.vikunja = {
      secret = secrets.pi.authelia.oidc.vikunja;
      redirect_uris = [
        "https://${secrets.pi.vikunja.domain}/auth/openid/authelia"
      ];
    };

    dashboard.vikunja = {
      icon = "vikunja.svg";
      description = "Todos";
      url = "https://${secrets.pi.vikunja.domain}";
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
      auth = {
        local.enabled = false;
        openid = {
          enabled = true;
          redirecturl = "https://${secrets.pi.vikunja.domain}/auth/openid/";
          providers = [
            {
              name = "Authelia";
              authurl = "https://${secrets.pi.authelia.domain}";
              clientid = "vikunja";
              clientsecret = secrets.pi.authelia.oidc.vikunja;
              scope = "openid profile email";
            }
          ];
        };
      };
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
