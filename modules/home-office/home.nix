{
  lib,
  config,
  pkgs,
  meta,
  ...
}:
let
  cfg = config.home-office;

in
{
  options.home-office = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.sshfs ];

      file.".local/bin/work" = {
        executable = true;
        source = ../../bin/work.sh;
      };
    };

    kibadda.ssh = [
      {
        name = "work-studies";
        host = meta.work.sshfs.studies;
        user = meta.work.sshfs.user;
        forward = false;
      }
    ];
  };
}
