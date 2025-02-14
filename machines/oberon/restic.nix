{
  meta,
  ...
}:
{
  services.restic.backups.daily = {
    initialize = true;

    environmentFile = "/etc/restic/env";
    passwordFile = "/etc/restic/pass";
    repository = meta.pi.backup.repository;

    extraBackupArgs = [
      "--skip-if-unchanged"
    ];

    paths = [
      meta.pi.gitea.dir
      meta.pi.immich.dir
      meta.pi.mealie.dir
    ];

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 3"
      "--keep-monthly 3"
    ];
  };

  environment.etc = {
    "restic/env".text = meta.pi.backup.environment;
    "restic/pass".text = meta.pi.backup.password;
  };
}
