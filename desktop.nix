{ pkgs, ... }: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
    binfmt.emulatedSystems = [ "aarch64-linux" ];
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
