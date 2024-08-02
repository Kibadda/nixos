{ lib, meta, ... }: {
  imports = [
    ../../modules/i3/home.nix
  ];

  programs.git = {
    userEmail = lib.mkForce "m.strobel@cortex-media.de";
    includes = [
      {
        condition = "gitdir:~/Projects/Personal/";
        contents.user.email = meta.email;
        contentSuffix = "personal-config";
      }
    ];
  };
}
