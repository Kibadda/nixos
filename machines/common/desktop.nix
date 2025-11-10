{
  pkgs,
  hostname,
  secrets,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.default
    ../${hostname}/disko.nix
    ../${hostname}/hardware-configuration.nix
  ];

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

  networking.networkmanager.enable = true;

  users.users.${secrets.base.username}.extraGroups = [ "networkmanager" ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "Hyprland";
        user = secrets.base.username;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    playerctl
    brightnessctl
    pamixer
    xdg-utils
    spotify
    telegram-desktop
    claude-code
    kibadda.nvimupdate
  ];
}
