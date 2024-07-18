{ config, pkgs, ... }: {
  enable = true;
  lfs.enable = true;
  userName = "Michael Strobel";
  userEmail = "mstrobel97@gmail.com";
  signing.key = "0x3B6861376B6D3D78";
  signing.signByDefault = true;
  extraConfig = {
    pull = {
      rebase = true;
    };
    init = {
      defaultBranch = "main";
    };
  };
}
