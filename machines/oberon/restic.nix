{
  meta,
  ...
}:
let
  restic =
    {
      path,
      name,
      time,
      exclude ? [ ],
    }:
    {
      initialize = true;
      environmentFile = "/etc/restic/env";
      passwordFile = "/etc/restic/pass";
      repository = "${meta.pi.backup.repository}-${name}";

      extraBackupArgs = [ "--skip-if-unchanged" ];

      paths = [ path ];

      exclude = exclude;

      timerConfig.OnCalendar = time;

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 3"
        "--keep-monthly 3"
      ];
    };
in
{
  services.restic.backups = {
    forgejo = restic {
      name = "forgejo";
      time = "23:00";
      path = meta.pi.forgejo.dir;
      exclude = [
        "tmp/**"
        "log/**"
      ];
    };

    immich = restic {
      name = "immich";
      time = "23:15";
      path = meta.pi.immich.dir;
    };

    mealie = restic {
      name = "mealie";
      time = "23:30";
      path = meta.pi.mealie.dir;
    };
  };

  environment.etc = {
    "restic/env".text = meta.pi.backup.environment;
    "restic/pass".text = meta.pi.backup.password;
  };
}
