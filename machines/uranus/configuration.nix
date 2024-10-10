{ config, meta, ... }: {
  programs.steam.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };
  networking.wg-quick.interfaces.work = meta.work.vpn;
}
