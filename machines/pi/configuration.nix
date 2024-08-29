{ lib, ... }: {
  raspberry-pi-nix.board = "bcm2711";

  services = {
    openssh.enable = true;
    k3s.enable = true;
  };

  networking = {
    networkmanager.enable = lib.mkForce false;
    interfaces.wlan0.useDHCP = true;
  };
}
