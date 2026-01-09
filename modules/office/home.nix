{
  lib,
  config,
  pkgs,
  inputs,
  secrets,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.office = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      atHome = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.office.enable {
    home = {
      packages = (lib.optional cfg.office.atHome pkgs.kibadda.work) ++ [
        pkgs.thunderbird
        pkgs.sshfs
        inputs.linphone-nixpkgs.legacyPackages."x86_64-linux".linphone
      ];

      file =
        (
          if cfg.office.atHome then
            {
              ".smbcredentials".text = secrets.work.smb.credentials;
            }
          else
            { }
        )
        // builtins.listToAttrs (
          builtins.concatMap (key: [
            {
              name = ".ssh/${key}";
              value.text = secrets.work.additionalSshKeys.${key}.private;
            }
            {
              name = ".ssh/${key}.pub";
              value.text = secrets.work.additionalSshKeys.${key}.public;
            }
          ]) (builtins.attrNames secrets.work.additionalSshKeys)
        );
    };

    programs = {
      sftpman = {
        enable = true;
        mounts = secrets.work.sshMounts;
      };

      firefox.profiles.work = {
        id = 1;
        isDefault = !cfg.office.atHome;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          vimium
          darkreader
          bitwarden
        ];
        settings = {
          "browser.startup.homepage" = "https://in.${secrets.work.domain}";
        };
        bookmarks = {
          force = true;
          settings = [
            {
              name = "Work";
              toolbar = true;
              bookmarks = [
                {
                  name = "Pizza";
                  url = "https://mybuks.de/pinocchio-ulm";
                }
                {
                  name = "Neocortex";
                  url = "https://in.${secrets.work.domain}";
                }
                {
                  name = "Git";
                  url = "https://git.${secrets.work.domain}";
                }
              ];
            }
          ];
        };
      };
    };

    kibadda = {
      ssh = {
        enable = true;
        hosts = secrets.work.sshHosts;
      };

      git.includes = lib.mkIf cfg.office.atHome [
        {
          condition = "gitdir:/mnt/studiesbeta/";
          contents = {
            user.email = secrets.work.email;
            pull.rebase = false;
          };
        }
        {
          condition = "gitdir:/mnt/beta/";
          contents = {
            user.email = secrets.work.email;
            pull.rebase = false;
          };
        }
      ];

      gnome.keybindings = lib.mkIf cfg.office.atHome {
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          name = "firefox work";
          command = "firefox -P work";
          binding = "<Control><Super>B";
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          ];
        };
      };
    };
  };
}
