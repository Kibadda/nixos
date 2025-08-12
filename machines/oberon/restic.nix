{
  secrets,
  config,
  lib,
  ...
}:
{
  options = {
    oberon.backup = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
            };
            time = lib.mkOption {
              type = lib.types.str;
            };
            exclude = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };
          };
        }
      );
      default = { };
    };
  };

  config = {
    services.restic.backups = builtins.mapAttrs (name: conf: {
      initialize = true;
      environmentFile = "/etc/restic/env";
      passwordFile = "/etc/restic/pass";
      repository = "${secrets.pi.backup.repository}-${name}";
      extraBackupArgs = [ "--skip-if-unchanged" ];
      paths = [ conf.path ];
      exclude = conf.exclude;
      timerConfig.OnCalendar = conf.time;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 3"
        "--keep-monthly 3"
      ];
    }) config.oberon.backup;

    environment.etc = {
      "restic/env".text = secrets.pi.backup.environment;
      "restic/pass".text = secrets.pi.backup.password;
    };
  };
}
