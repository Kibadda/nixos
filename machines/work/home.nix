{ pkgs, meta, ... }: {
  kibadda = {
    i3.enable = true;

    packages = with pkgs; [
      linphone
      thunderbird
      rocketchat-desktop
    ];

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
