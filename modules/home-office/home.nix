{
  lib,
  config,
  pkgs,
  secrets,
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
    home.packages = [ pkgs.kibadda.work ];

    kibadda.ssh.hosts = [
      {
        name = "work-studies";
        host = secrets.work.sshfs.studies;
        user = secrets.work.sshfs.user;
        forward = false;
      }
    ];
  };
}
