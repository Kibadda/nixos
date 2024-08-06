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
      email = "m.strobel@cortex-media.de";
      extraConfig = {
        includes = [
          {
            condition = "gitdir:~/Projects/Personal/";
            contents.user.email = meta.email;
          }
        ];
      };
    };

    neovim.dir = "$HOME/Projects/Personal/neovim";
  };
}
