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
    kibadda.vpn = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.vpn.enable {
    home.packages = [ pkgs.kibadda.home ];
  };
}
