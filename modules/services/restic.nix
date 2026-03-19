{
  lib,
  secrets,
  ...
}:
{
  flake.nixosModules.restic =
    {
      config,
      ...
    }:
    {
      services.restic.backups = builtins.mapAttrs (name: service: {
        initialize = true;
        environmentFile = "/etc/restic/env";
        passwordFile = "/etc/restic/pass";
        repository = "${secrets.pi.restic.repository}-dendritic-${name}";
        extraBackupArgs = [ "--skip-if-unchanged" ];
        paths = service.backup.paths;
        timerConfig.OnCalendar = service.backup.time;
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 3"
          "--keep-monthly 3"
        ];
      }) (lib.filterAttrs (_: service: service.backup != null) config.kibadda.services);

      environment.etc = {
        "restic/env".text = secrets.pi.restic.environment;
        "restic/pass".text = secrets.pi.restic.password;
      };
    };
}
