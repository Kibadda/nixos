{
  inputs,
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

  environment.systemPackages = with pkgs; [
    playerctl
    brightnessctl
    pamixer
  ];
}
