{
  inputs,
  secrets,
  ...
}:
{
  imports = [
    inputs.nixos-generators.nixosModules.sd-aarch64
    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    ../common/configuration.nix
    ../common/home.nix

    ../../modules/zsh/configuration.nix

    ./n8n.nix
  ];

  services.glances = {
    enable = true;
    openFirewall = true;
  };

  networking = {
    wireless = {
      enable = true;
      networks.${secrets.home.wifi."5.0"}.psk = secrets.home.wifi.pass;
    };
    interfaces.wlan0.useDHCP = true;
  };

  nixpkgs = {
    hostPlatform = "aarch64-linux";
    # FIX: cross compiling https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
    overlays = [
      (final: prev: {
        makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };
}
