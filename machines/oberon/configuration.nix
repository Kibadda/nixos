{
  inputs,
  meta,
  ...
}:
{
  imports = [
    inputs.nixos-generators.nixosModules.sd-aarch64
    inputs.home-manager.nixosModules.home-manager

    ../common/configuration.nix
    ../common/home.nix

    ../../modules/zsh/configuration.nix
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = meta.email;
  };

  services = {
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      virtualHosts = {
        "fotos.${meta.pi.domain}" = {
          enableACME = true;
          forceSSL = true;
          basicAuth = meta.pi.users;
          locations."/".proxyPass = "http://localhost:2283";
        };

        "essen.${meta.pi.domain}" = {
          enableACME = true;
          forceSSL = true;
          basicAuth = meta.pi.users;
          locations."/".proxyPass = "http://localhost:9000";
        };
      };
    };

    immich = {
      enable = true;
      openFirewall = true;
      # FIX: tests for this are failing
      machine-learning.enable = false;
      settings = {
        server.externalDomain = "https://fotos.${meta.pi.domain}";
        storageTemplate = {
          enabled = true;
          template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
        };
      };
    };

    mealie = {
      enable = true;
    };
  };

  networking = {
    wireless = {
      enable = true;
      networks.${meta.wifi.ssid}.psk = meta.wifi.pass;
    };
    interfaces.wlan0.useDHCP = true;
    firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
