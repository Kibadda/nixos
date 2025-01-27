{ pkgs, meta, ... }:
{
  home.packages = with pkgs; [
    linphone
    thunderbird
    rocketchat-desktop
  ];

  kibadda = {
    i3.enable = true;

    firefox.enable = true;

    git = {
      email = meta.work.email;
      includes = [
        {
          condition = "gitdir:~/Projects/Personal/";
          contents.user.email = meta.email;
        }
      ];
    };
  };
}
