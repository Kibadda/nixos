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
        immich = {
          default = true;
          enableACME = true;
          forceSSL = true;
          serverName = "fotos.xn--strobel-s-o1a23a.de";
          locations."/".proxyPass = "http://localhost:2283";
        };

        mealie = {
          enableACME = true;
          forceSSL = true;
          serverName = "essen.xn--strobel-s-o1a23a.de";
          locations."/".proxyPass = "http://loaclhost:9000";
        };
      };
    };

    immich = {
      enable = true;
      openFirewall = true;
      # FIX: tests for this are failing
      machine-learning.enable = false;
      settings = {
        server.externalDomain = "https://fotos.xn--strobel-s-o1a23a.de";
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
      9000
    ];
  };
}
