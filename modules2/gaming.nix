{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.gaming;
in
{
  options = {
    gaming = {
      steam.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      lutris.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      chiaki.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = {
    environment.systemPackages =
      [ ]
      ++ (lib.optional cfg.lutris.enable pkgs.lutris)
      ++ (lib.optional cfg.chiaki.enable pkgs.chiaki-ng);

    programs.steam.enable = cfg.steam.enable;
  };
}
