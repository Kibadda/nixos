{
  self,
  secrets,
  ...
}:
{
  nixosConfigurations.titania = {
    system = "x86_64-linux";

    configuration = {
      kibadda.vpn.home = true;
    };

    home = {
      kibadda = {
        ssh.hosts = [
          {
            name = "uranus";
            host = "10.0.0.10";
            port = secrets.home.sshPort;
            forward = true;
          }
          {
            name = "oberon";
            host = "10.0.0.3";
            port = secrets.home.sshPort;
          }
          {
            name = "umbriel";
            host = "10.0.0.4";
            port = secrets.home.sshPort;
          }
        ];
      };
    };

    nixosModules = [
      self.nixosModules.desktop

      self.nixosModules.yubikey
      self.nixosModules.zsh

      self.nixosModules.gnome
      self.nixosModules.vpn
    ];

    homeModules = [
      self.homeModules.desktop

      self.homeModules.yubikey
      self.homeModules.zsh

      self.homeModules.direnv
      self.homeModules.eza
      self.homeModules.firefox
      self.homeModules.git
      self.homeModules.kitty
      self.homeModules.neovim
      self.homeModules.ssh
      self.homeModules.zoxide
    ];

    hardware =
      { modulesPath, ... }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        networking.interfaces = {
          enp4s0.useDHCP = true;
          wlp5s0.useDHCP = true;
        };

        boot = {
          initrd = {
            availableKernelModules = [
              "xhci_pci"
              "nvme"
              "usb_storage"
              "sd_mod"
              "sdhci_pci"
            ];
            kernelModules = [ ];
          };
          kernelModules = [ ];
          extraModulePackages = [ ];
        };

        powerManagement.cpuFreqGovernor = "powersave";
        hardware.cpu.intel.updateMicrocode = true;
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
