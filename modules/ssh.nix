{
  config,
  lib,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.ssh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      hosts = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
              };

              host = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };

              port = lib.mkOption {
                type = lib.types.nullOr lib.types.int;
                default = null;
              };

              forward = lib.mkOption {
                type = lib.types.bool;
                default = true;
              };

              user = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
            };
          }
        );
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.ssh.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = builtins.listToAttrs (
        map (config: {
          name = config.name;
          value = {
            hostname = config.host;
            port = config.port;
            user = config.user;
            remoteForwards = lib.mkIf config.forward [
              {
                bind.address = "/run/user/1000/gnupg/S.gpg-agent.ssh";
                host.address = "/run/user/1000/gnupg/S.gpg-agent.ssh";
              }
              {
                bind.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
                host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
              }
            ];
          };
        }) cfg.ssh.hosts
      );
    };
  };
}
