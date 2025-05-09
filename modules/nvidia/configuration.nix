{
  config,
  meta,
  lib,
  ...
}:
let
  cfg = config.home-manager.users.${meta.username}.kibadda;
in
{
  config = lib.mkIf cfg.nvidia.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware = {
      graphics.enable = true;
      nvidia = {
        open = true;
        modesetting.enable = true;
        package = config.boot.kernelPackages.nvidiaPackages.production;
      };
    };
  };
}
