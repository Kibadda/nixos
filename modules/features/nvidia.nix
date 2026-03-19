{
  flake.nixosModules.nvidia =
    {
      config,
      ...
    }:
    {
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
