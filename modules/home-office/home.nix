{
  lib,
  config,
  pkgs,
  meta,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.home-office = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.home-office.enable {
    home = {
      packages = [ pkgs.sshfs ];

      file.".local/bin/work" = {
        executable = true;
        source = ../../bin/work.sh;
      };
    };

    kibadda.ssh.hosts = [
      {
        name = "work-studies";
        host = meta.work.sshfs.studies;
        user = meta.work.sshfs.user;
        forward = false;
      }
    ];
  };
}
