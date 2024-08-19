{ pkgs, meta, ... }: {
  kibadda = {
    i3.enable = true;

    packages = with pkgs; [
      linphone
      thunderbird
      rocketchat-desktop
    ];

    browser = "firefox";

    git = {
      email = meta.email.work;
      includes = [
        {
          condition = "gitdir:~/Projects/Personal/";
          contents.user.email = meta.email.personal;
        }
      ];
    };
  };
}
