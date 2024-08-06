{ lib, pkgs, meta, ... }: {
  imports = [
    ../../modules/kibadda.nix
  ];

  kibadda = {
    i3.enable = true;

    packages.home = with pkgs; [
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

  networking.hostName = lib.mkForce "michael-5824";
}
