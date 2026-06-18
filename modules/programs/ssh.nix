{
  lib,
  ...
}:
{
  flake.homeModules.ssh =
    {
      config,
      ...
    }:
    {
      options.kibadda.ssh.hosts = lib.mkOption {
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
                default = false;
              };

              user = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };

              identity = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
            };
          }
        );
        default = [ ];
      };

      config = {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings =
            let
              blocks = builtins.listToAttrs (
                map (config: {
                  name = config.name;
                  value = {
                    HostName = config.host;
                    Port = config.port;
                    User = config.user;
                    IdentityFile = lib.mkIf (config.identity != null) "~/.ssh/${config.identity}";
                    RemoteForward = lib.mkIf config.forward [
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
                }) config.kibadda.ssh.hosts
              );
            in
            blocks
            // {
              "*" = {
                ForwardAgent = false;
                AddKeysToAgent = "no";
                Compression = false;
                ServerAliveInterval = 0;
                ServerAliveCountMax = 3;
                HashKnownHosts = false;
                UserKnownHostsFile = "~/.ssh/known_hosts";
                ControlMaster = "no";
                ControlPath = "~/.ssh/master-%r@%n:%p";
                ControlPersist = "no";
              };
            };
          # matchBlocks =
          #   let
          #     blocks = builtins.listToAttrs (
          #       map (config: {
          #         name = config.name;
          #         value = {
          #           hostname = config.host;
          #           port = config.port;
          #           user = config.user;
          #           identityFile = lib.mkIf (config.identity != null) "~/.ssh/${config.identity}";
          #           remoteForwards = lib.mkIf config.forward [
          #             {
          #               bind.address = "/run/user/1000/gnupg/S.gpg-agent.ssh";
          #               host.address = "/run/user/1000/gnupg/S.gpg-agent.ssh";
          #             }
          #             {
          #               bind.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
          #               host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
          #             }
          #           ];
          #         };
          #       }) config.kibadda.ssh.hosts
          #     );
          #   in
          #   blocks
          #   // {
          #     "*" = {
          #       forwardAgent = false;
          #       addKeysToAgent = "no";
          #       compression = false;
          #       serverAliveInterval = 0;
          #       serverAliveCountMax = 3;
          #       hashKnownHosts = false;
          #       userKnownHostsFile = "~/.ssh/known_hosts";
          #       controlMaster = "no";
          #       controlPath = "~/.ssh/master-%r@%n:%p";
          #       controlPersist = "no";
          #     };
          #   };
        };
      };
    };
}
