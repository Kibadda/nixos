{ config, lib, pkgs, ... }: {
  programs.ssh.startAgent = false;

  environment = {
    systemPackages = with pkgs; [
      gnupg
      yubikey-personalization
    ];
    shellInit = ''
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
    '';
  };

  services = {
    udev.packages = with pkgs; [
      yubikey-personalization
    ];
    pcscd.enable = true;
  };

  security.pam.services = {
    sudo.u2fAuth = true;
  };
}
