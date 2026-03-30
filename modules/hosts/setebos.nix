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

        programs.nix-ld = {
          enable = true;
          libraries = with pkgs; [
            stdenv.cc.cc.lib
            zlib
            glibc
          ];
        };

        environment = {
          systemPackages = with pkgs; [
            cifs-utils
            android-tools
            gradle
            jdk17
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

    home = {
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

        config-directory = "Projects/Personal/nixos";
      };

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
      self.homeModules.config-checker
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
