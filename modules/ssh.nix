{ config, lib, ... }: let
  cfg = config.kibadda;
in {
  config = lib.mkIf (cfg.ssh != []) {
    programs.ssh = {
      enable = true;
      matchBlocks = builtins.listToAttrs (map (config: {
        name = config.name;
        value = {
          hostname = config.host;
          port = config.port;
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
      }) cfg.ssh);
    };
  };
}
