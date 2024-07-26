{ lib, ... }: {
  imports = [
    ../../modules/i3/home.nix
  ];

  programs.git.userEmail = lib.mkForce "m.strobel@cortex-media.de";
}
