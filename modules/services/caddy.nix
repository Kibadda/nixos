{
  lib,
  secrets,
  ...

}:
{
  flake.nixosModules.caddy =
    {
      config,
      pkgs,
      ...
    }:
    let
      domain = secrets.pi.domain;
      authelia-port = 9091;
      dashboard-port = 8082;
      auth = ''
        forward_auth 127.0.0.1:${builtins.toString authelia-port} {
          uri /api/authz/forward-auth
          copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
        }
      '';
      deny = ''
        @denied {
          not remote_ip ${secrets.pi.ip}
          not path /.well-known/acme-challenge/*
        }
        respond @denied "Forbidden" 403
      '';
    in
    {
      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/netcup@v1.0.0" ];
          hash = "sha256-rIImoqXFgbEfgygoGguwATCZV3B6IImRjU+g92IlCtE=";
        };
        email = secrets.base.email;
        globalConfig = ''
          debug
          acme_dns netcup {
            customer_number ${secrets.pi.netcup.customer_number}
            api_key ${secrets.pi.netcup.api_key}
            api_password ${secrets.pi.netcup.api_password}
          }
        '';
        virtualHosts."*.${domain}, ${domain}".extraConfig = ''
          tls {
            dns netcup {
              customer_number ${secrets.pi.netcup.customer_number}
              api_key ${secrets.pi.netcup.api_key}
              api_password ${secrets.pi.netcup.api_password}
            }
            propagation_timeout 900s
            propagation_delay 600s
            resolvers 1.1.1.1 8.8.8.8
          }

          header -Server

          @sso host sso.${domain}
          handle @sso {
            reverse_proxy 127.0.0.1:${builtins.toString authelia-port}
          }

          @dashboard host dashboard.${domain}
          handle @dashboard {
            ${auth}
            reverse_proxy 127.0.0.1:${builtins.toString dashboard-port}
          }

          ${lib.concatStringsSep "\n" (
            builtins.map (service: ''
              @${service.subdomain} host ${service.subdomain}.${domain}
              handle @${service.subdomain} {
                ${lib.optionalString (!service.open) deny}
                ${lib.optionalString (service.auth == "forward") auth}
                ${service.extra}
                reverse_proxy ${service.host}:${builtins.toString service.port}
              }
            '') (builtins.attrValues config.kibadda.services)
          )}
        '';
      };
    };
}
