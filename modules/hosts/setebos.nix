{
  self,
  secrets,
  ...
}:
{
  nixosConfigurations.setebos = {
    system = "x86_64-linux";

    configuration =
      {
        pkgs,
        ...
      }:
      {
        kibadda = {
          vpn.home = true;

          gnome = {
            settings = {
              "org/gnome/settings-daemon/plugins/media-keys" = {
                next = [ "<Control><Super>j" ];
                play = [ "<Control><Super>space" ];
                previous = [ "<Control><Super>k" ];
              };
            };

            keybindings = [
              {
                name = "firefox personal";
                command = "firefox -P ${secrets.base.username}";
                binding = "<Control><Super>B";
              }
            ];
          };
        };

        environment = {
          systemPackages = [
            pkgs.cifs-utils
          ];

          etc."nixos/smbcredentials".text = secrets.work.smb.credentials;
        };

        fileSystems = {
          "/mnt/team" = {
            device = "//${secrets.work.smb.ip}/team";
            fsType = "cifs";
            options = [ "nofail,credentials=/etc/nixos/smbcredentials,uid=1000,gid=1000" ];
          };

          "/mnt/temp" = {
            device = "//${secrets.work.smb.ip}/temp";
            fsType = "cifs";
            options = [ "nofail,credentials=/etc/nixos/smbcredentials,uid=1000,gid=1000" ];
          };
        };
      };

    home =
      {
        pkgs,
        ...
      }:
      {
        kibadda = {
          ssh.hosts = [
            {
              name = "oberon";
              host = "10.0.0.3";
              port = secrets.home.sshPort;
            }
          ];

          git = {
            settings = {
              user.email = secrets.work.email;
              pull.rebase = false;
            };

            includes = [
              {
                condition = "gitdir:~/Projects/Personal/";
                contents = {
                  user.email = secrets.base.email;
                  pull.rebase = true;
                };
              }
              {
                condition = "gitdir:~/Projects/neovim/";
                contents = {
                  user.email = secrets.base.email;
                  pull.rebase = true;
                };
              }
            ];
          };
        };

        home.packages = [ pkgs.android-studio ];

        programs.firefox.profiles.work.isDefault = true;
      };

    nixosModules = [
      self.nixosModules.desktop

      self.nixosModules.yubikey
      self.nixosModules.zsh
      self.nixosModules.office

      self.nixosModules.gnome
      self.nixosModules.vpn
      self.nixosModules.nvidia
    ];

    homeModules = [
      self.homeModules.desktop

      self.homeModules.yubikey
      self.homeModules.zsh
      self.homeModules.office

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

        networking.interfaces.enp4s0.useDHCP = true;

        boot = {
          initrd = {
            availableKernelModules = [
              "nvme"
              "xhci_pci"
              "ahci"
              "usbhid"
              "usb_storage"
              "sd_mod"
            ];
            kernelModules = [ ];
          };
          kernelModules = [ ];
          extraModulePackages = [ ];
        };

        hardware.cpu.amd.updateMicrocode = true;
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
