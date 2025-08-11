{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.gaming = {
      steam = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      lutris = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      chiaki = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      bottles = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = {
    home.packages =
      (lib.optional cfg.gaming.lutris pkgs.lutris)
      ++ (lib.optional cfg.gaming.chiaki pkgs.chiaki-ng)
      ++ (lib.optional cfg.gaming.bottles (
        pkgs.bottles.override {
          removeWarningPopup = true;
        }
      ))
      ++ [ ];
  };
}
