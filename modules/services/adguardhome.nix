{
  flake.nixosModules.adguardhome = {
    kibadda.services.adguardhome = {
      description = "Adblocker";
      subdomain = "ad";
      port = 3000;
      auth = "none";
    };

    networking.firewall = {
      allowedTCPPorts = [
        53
      ];
      allowedUDPPorts = [
        53
      ];
    };

    services.adguardhome = {
      enable = true;
      mutableSettings = false;
      settings = {
        http.address = "0.0.0.0:3000";
        dns = {
          upstream_dns = [
            "https://dns.cloudflare.com/dns-query"
            "https://dns.google/dns-query"
            "https://doh.mullvad.net/dns-query"
          ];
          fallback_dns = [
            "1.1.1.1"
          ];
          bootstrap_dns = [
            "1.1.1.1"
          ];
        };
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
        };
        querylog = {
          enabled = true;
          interval = "24h";
        };
        statistics = {
          enabled = true;
          interval = "24h";
        };
        filters = [
          {
            name = "HaGeZi Multi Pro";
            url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
            enabled = true;
          }
          {
            name = "AdGuard DNS filter";
            url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
            enabled = true;
          }
        ];
      };
    };
  };
}
