{
  lib,
  config,
  pkgs,
  secrets,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.home-office = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.home-office.enable {
    home.packages = [
      pkgs.kibadda.work
      pkgs.thunderbird
      # pkgs.linphone
    ];

    programs = {
      zsh.shellAliases.smbmount = "sudo mount -t cifs -o username=${secrets.work.smb.username},password=${secrets.work.smb.password},uid=1000,gid=1000 //${secrets.work.smb.ip}/team /mnt/team";

      firefox.profiles.work = {
        id = 1;
        isDefault = false;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          vimium
          darkreader
        ];
        settings = {
          "browser.startup.homepage" = "https://${secrets.work.domain}";
        };
        bookmarks = {
          force = true;
          settings = [
            {
              name = "Work";
              toolbar = true;
              bookmarks = [
                {
                  name = "Chat";
                  url = "https://rocket.${secrets.work.domain}";
                }
                {
                  name = "Pass";
                  url = "https://passwords.${secrets.work.domain}";
                }
              ];
            }
          ];
        };
      };
    };

    kibadda = {
      hypr.bind = [
        "SUPER CONTROL, B, exec, firefox -P work"
      ];

      git.includes = [
        {
          condition = "gitdir:/mnt/studiesbeta/";
          contents.user.email = secrets.work.email;
        }
      ];

      ssh.hosts = [
        {
          name = "work-studies";
          host = secrets.work.sshfs.studies;
          user = secrets.work.sshfs.user;
          forward = false;
        }
      ];
    };
  };
}
