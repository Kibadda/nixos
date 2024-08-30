{ meta, ... }: {
  raspberry-pi-nix.board = "bcm2711";

  services = {
    openssh.enable = true;
    k3s.enable = true;
  };

  networking = {
    wireless = {
      enable = true;
      networks.${meta.wifi.ssid}.psk = meta.wifi.pass;
    };
    interfaces.wlan0.useDHCP = true;
  };
}
