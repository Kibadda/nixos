{
  self,
  secrets,
  ...
}:
{
  nixosConfigurations.uranus = {
    system = "x86_64-linux";

    configuration = { };

    home =
      {
        pkgs,
        ...
      }:
      {
        home.packages = [
          pkgs.chiaki-ng
        ];

        kibadda = {
          ssh.hosts = [
            {
              name = "titania";
              host = "10.0.0.11";
              port = secrets.home.sshPort;
              forward = true;
            }
            {
              name = "oberon";
              host = "10.0.0.3";
              port = secrets.home.sshPort;
            }
          ];
        };
      };

    nixosModules = [
      self.nixosModules.desktop

      self.nixosModules.yubikey
      self.nixosModules.zsh
      self.nixosModules.homeoffice

      self.nixosModules.ausweisapp
      self.nixosModules.gnome
      self.nixosModules.nvidia
      self.nixosModules.vpn
      self.nixosModules.steam
    ];

    homeModules = [
      self.homeModules.desktop

      self.homeModules.yubikey
      self.homeModules.zsh
      self.homeModules.homeoffice

      self.homeModules.direnv
      self.homeModules.eza
      self.homeModules.firefox
      self.homeModules.git
      self.homeModules.kitty
      self.homeModules.neovim
      self.homeModules.ssh
      self.homeModules.zoxide
    ];

    hardware = {
      networking.interfaces.enp4s0.useDHCP = true;

      boot = {
        initrd = {
          availableKernelModules = [
            "xhci_pci"
            "nvme"
            "usb_storage"
            "sd_mod"
            "ahci"
            "usbhid"
          ];
          kernelModules = [ ];
        };
        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];
      };

      hardware = {
        enableRedistributableFirmware = true;
        cpu.amd.updateMicrocode = true;
      };
    };

    disko = {
      devices.disk.main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
