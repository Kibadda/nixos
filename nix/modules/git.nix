{ config, pkgs, meta, ... }: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = meta.name;
    userEmail = meta.email;
    signing = {
      key = meta.keyid;
      # enable after renewing yubikey subkeys
      signByDefault = false;
    };
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };
}
