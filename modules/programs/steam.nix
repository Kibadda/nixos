{
  flake.nixosModules.steam =
    {
      pkgs,
      ...
    }:
    {
      programs = {
        steam = {
          enable = true;
          package = pkgs.steam.override {
            extraEnv = {
              MANGOHUD = 1;
              MANGOHUD_CONFIG = "read_cfg";
              GAMEMODERUN = 1;
            };
          };
          gamescopeSession.enable = true;
          remotePlay.openFirewall = true;
        };

        gamemode.enable = true;
      };

      environment.systemPackages = [
        pkgs.mangohud
      ];
    };
}
