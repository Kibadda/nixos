{
  inputs,
  secrets,
  self,
  ...
}:
{
  flake.homeModules.server = {
    imports = [
      self.homeModules.base
    ];
  };

  flake.nixosModules.server =
    {
      modulesPath,
      ...
    }:
    {
      imports = [
        self.nixosModules.base
        "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
      ];

      boot = {
        zfs.forceImportRoot = false;
        supportedFilesystems.zfs = false;
      };

      sdImage.compressImage = false;

      networking.wireless = {
        enable = true;
        networks.${secrets.home.wifi."5.0"}.psk = secrets.home.wifi.pass;
      };

      nixpkgs.overlays = [
        # FIX: cross compiling https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
        (final: prev: {
          makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
        })
      ];
    };
}
