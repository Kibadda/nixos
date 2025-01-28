{
  meta,
  ...
}:
{
  nixpkgs = {
    system = "aarch64-linux";
    overlays = [
      (final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = meta.email;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  services = {
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      virtualHosts.immich = {
        default = true;
        enableACME = true;
        forceSSL = true;
        serverName = "fotos2.xn--strobel-s-o1a23a.de";
        locations."/".proxyPass = "http://localhost:2283";
      };
    };

    immich = {
      enable = true;
      openFirewall = true;
      settings = {
        server.externalDomain = "https://fotos2.xn--strobel-s-o1a23a.de";
        storageTemplate = {
          enabled = true;
          template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
        };
      };
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
