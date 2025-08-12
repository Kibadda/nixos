{
  inputs,
  secrets,
  pkgs,
  ...
}:
{
  imports = [
    (import "${inputs.mobile-nixos}/lib/configuration.nix" { device = "oneplus-enchilada"; })

    ../common/configuration.nix
    ../common/home.nix

    ../../modules/kibadda/configuration.nix
  ];

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
  ];

  networking = {
    wireless = {
      enable = true;
      networks.${secrets.home.wifi."2.4"}.psk = secrets.home.wifi.pass;
    };
  };
}
