{
  secrets,
  ...
}:
{
  imports = [
    ../../modules/kibadda/home.nix
  ];

  kibadda = {
    firefox = {
      enable = true;
      defaultProfile = "work";
    };

    office.enable = true;

    vpn.enable = true;

    nvidia.enable = true;

    ssh = {
      enable = true;
      hosts = [
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
      ];
    };

    gnome = {
      enable = true;

      settings = {
        "org/gnome/settings-daemon/plugins/media-keys" = {
          next = [ "<Control><Super>j" ];
          play = [ "<Control><Super>space" ];
          previous = [ "<Control><Super>k" ];
        };
      };
    };

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
        {
          condition = "gitdir:~/nixos/";
          contents = {
            user.email = secrets.base.email;
            pull.rebase = true;
          };
        }
        {
          condition = "gitdir:~/.config/nvim/";
          contents = {
            user.email = secrets.base.email;
            pull.rebase = true;
          };
        }
      ];
    };
  };
}
