{
  inputs,
  meta,
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
  ];

  networking = {
    wireless = {
      enable = true;
      networks.${meta.wifi.ssid2}.psk = meta.wifi.pass;
    };
  };
}
