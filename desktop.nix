{ pkgs, ... }: {
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    playerctl
    brightnessctl
    pamixer
    xdg-utils
    spotify
    telegram-desktop
  ];
}
