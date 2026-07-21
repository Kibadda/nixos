{
  inputs,
  secrets,
  self,
  ...
}:
{
  nixosConfigurations.oberon = {
    system = "aarch64-linux";
    nixpkgs = inputs.server-nixpkgs;

    configuration = {
      networking.firewall = {
        allowedTCPPorts = [
          80
          443
        ];

        extraCommands = ''
          iptables -I nixos-fw -p tcp -s 10.0.0.0/24 --dport ${toString secrets.home.sshPort} -j nixos-fw-accept
        '';
      };

      services.openssh.openFirewall = false;

      services.beszel.agent.environment.EXTRA_FILESYSTEMS = "sda1";
    };

    home = { };

    nixosModules = [
      self.nixosModules.server

      self.nixosModules.zsh

      self.nixosModules.services
      self.nixosModules.caddy
      self.nixosModules.authelia
      self.nixosModules.backup
      self.nixosModules.adguardhome
      self.nixosModules.fail2ban
      self.nixosModules.beszel-server
      self.nixosModules.beszel-client

      self.nixosModules.dashboard
      self.nixosModules.immich
      self.nixosModules.vaultwarden
      self.nixosModules.mealie
      self.nixosModules.trilium
      self.nixosModules.home-assistant
      self.nixosModules.it-tools
      self.nixosModules.stirling
      self.nixosModules.nextcloud
      self.nixosModules.trek
      self.nixosModules.marathon-tracker
      self.nixosModules.mindwtr

      # self.nixosModules.n8n
      # self.nixosModules.freshrss
      # self.nixosModules.paperless
    ];

    homeModules = [
      self.homeModules.server

      self.homeModules.zsh

      self.homeModules.kitty
      self.homeModules.eza
      self.homeModules.zoxide
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
