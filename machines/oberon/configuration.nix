{
  inputs,
  meta,
  ...
}:
{
  imports = [
    inputs.nixos-generators.nixosModules.sd-aarch64
    inputs.nixos-hardware.nixosModules.raspberry-pi-4

    ../common/configuration.nix
    ../common/home.nix

    ../../modules/zsh/configuration.nix

    ./nginx.nix
    ./immich.nix
    ./mealie.nix
    ./forgejo.nix
    ./vaultwarden.nix
    ./home-assistant
    ./restic.nix
  ];

  networking = {
    wireless = {
      enable = true;
      networks.${meta.wifi.ssid}.psk = meta.wifi.pass;
    };
    interfaces.wlan0.useDHCP = true;
    firewall.allowedTCPPorts = [
      80
      443
    ];
  };

  fileSystems = {
    "/mnt" = {
      device = "/dev/disk/by-uuid/bc76ab1a-8f4a-4d9b-9846-436419d779be";
      fsType = "ext4";
    };
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
