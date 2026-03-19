{
  inputs,
  self,
  ...
}:
{
  nixosConfigurations.oberon = {
    system = "aarch64-linux";
    nixpkgs = inputs.server-nixpkgs;

    configuration = {
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      services.beszel.agent.environment.EXTRA_FILESYSTEMS = "sda1";
    };

    home = { };

    homeModules = [
      self.homeModules.server

      self.homeModules.zsh

      self.homeModules.kitty
      self.homeModules.eza
      self.homeModules.zoxide
    ];

    nixosModules = [
      self.nixosModules.server

      self.nixosModules.zsh

      self.nixosModules.services
      self.nixosModules.caddy
      self.nixosModules.authelia
      self.nixosModules.restic
      self.nixosModules.adguardhome

      self.nixosModules.fail2ban
      self.nixosModules.beszel-server
      self.nixosModules.beszel-client
      self.nixosModules.dashboard
      self.nixosModules.immich
      self.nixosModules.vaultwarden
      self.nixosModules.mealie
      self.nixosModules.trilium
      self.nixosModules.paperless
      self.nixosModules.home-assistant
      self.nixosModules.psitransfer
    ];

    hardware = {
      networking.interfaces.wlan0.useDHCP = true;

      fileSystems = {
        "/mnt" = {
          device = "/dev/disk/by-uuid/bc76ab1a-8f4a-4d9b-9846-436419d779be";
          fsType = "ext4";
        };
      };
    };
  };
}
