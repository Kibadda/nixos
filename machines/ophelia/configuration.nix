{
  inputs,
  meta,
  ...
}:
{
  imports = [
    (import "${inputs.mobile-nixos}/lib/configuration.nix" { device = "oneplus-enchilada"; })

    ../common/configuration.nix
    ../common/home.nix

    ../../modules/kibadda/configuration.nix
  ];

  networking = {
    wireless = {
      enable = true;
      networks.${meta.wifi.ssid2}.psk = meta.wifi.pass;
    };
  };
}
