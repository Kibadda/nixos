{ pkgs, ... }: {
  programs.yubikey-touch-detector.enable = true;

  environment.systemPackages = with pkgs; [ gnupg yubikey-personalization ];

  security.pam.services = {
    sudo.u2fAuth = true;
    login.u2fAuth = true;
  };

  services = {
    udev.packages = with pkgs; [ yubikey-personalization ];
    pcscd.enable = true;
  };
}
