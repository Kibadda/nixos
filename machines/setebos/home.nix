{
  secrets,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/kibadda/home.nix
  ];

  home.packages = [ pkgs.android-studio ];

  kibadda = {
    firefox = {
      enable = true;
      defaultProfile = "work";
    };

    office.enable = true;

    vpn.home = secrets.home.vpn;

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

      custom-keybindings = [
        {
          name = "firefox personal";
          command = "firefox -P ${secrets.base.username}";
          binding = "<Control><Super>B";
        }
      ];
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
      ];
    };
  };
}
