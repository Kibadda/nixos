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
      pkgs,
      ...
    }:
    {
      imports = [
        self.nixosModules.base
        # FIX: how do i set fileSystems root now?
        inputs.nixos-generators.nixosModules.sd-aarch64
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
      ];

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
