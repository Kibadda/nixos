{ pkgs, meta, ... }: {
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

  users.users.${meta.username}.extraGroups = [ "networkmanager" ];

  services.greetd =  {
    enable = true;
    package = pkgs.greetd.tuigreet;
    settings = {
      default_session = {
        command = "Hyprland";
        user = meta.username;
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
  ];
}
