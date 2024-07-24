{ config, pkgs, meta, ... }: {
  enable = true;
  lfs.enable = true;
  userName = meta.name;
  userEmail = meta.email;
  signing = {
    key = meta.keyid;
    signByDefault = true;
  };
  extraConfig = {
    pull.rebase = true;
    init.defaultBranch = "main";
  };
}
