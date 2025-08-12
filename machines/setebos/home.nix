{
  pkgs,
  secrets,
  ...
}:
{
  imports = [
    ../../modules/kibadda/home.nix
  ];

  home.packages = with pkgs; [
    linphone
    thunderbird
    rocketchat-desktop
  ];

  kibadda = {
    i3.enable = true;

    firefox.enable = true;

    git = {
      email = secrets.work.email;
      includes = [
        {
          condition = "gitdir:~/Projects/Personal/";
          contents.user.email = secrets.base.email;
        }
      ];
    };
  };
}
