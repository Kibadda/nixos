{ pkgs, lib, ... }: {
  imports = [
    ../../modules/i3/default.nix
  ];

  environment.systemPackages = with pkgs; [
    linphone
    firefox
    thunderbird
    rocketchat-desktop
  ];

  networking.hostName = lib.mkForce "michael-5824";
}
