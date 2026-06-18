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
      auth = ''
        forward_auth 127.0.0.1:${toString config.kibadda.services.authelia.port} {
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
      netcup = ''
        customer_number ${secrets.pi.netcup.customer_number}
        api_key ${secrets.pi.netcup.api_key}
        api_password ${secrets.pi.netcup.api_password}
      '';
    in
    {
      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/netcup@v1.0.0" ];
          hash = "sha256-WRX4/RzshpC6CdtEImw+pRs14qQFh9zuWSSGdU4ZDgU=";
        };
        email = secrets.base.email;
        globalConfig = ''
          debug
          acme_dns netcup {
            ${netcup}
          }
        '';
        virtualHosts."fotos.strobel-süß.de".extraConfig = ''
          redir ${config.kibadda.services.immich.url}{uri} permanent
        '';
        virtualHosts."*.${secrets.pi.domain}, ${secrets.pi.domain}".extraConfig = ''
          tls {
            dns netcup {
              ${netcup}
            }
            propagation_timeout 900s
            propagation_delay 600s
            resolvers 1.1.1.1 8.8.8.8
          }

          header {
            -Server
            -X-Powered-By
            -Via

            X-Content-Type-Options nosniff
            X-Frame-Options SAMEORIGIN
            Referrer-Polixy strict-origin-when-cross-origin
            Strict-Transport-Security "max-age=604800; includeSubdomains; reload"
            Permissions-Policy "camera=(), microphone=(), geolocation=(), interest-cohort=()"
          }

          ${lib.concatStringsSep "\n" (
            map (service: ''
              @${service.subdomain} host ${service.hostname}
              handle @${service.subdomain} {
                ${lib.optionalString (!service.open) deny}
                ${lib.optionalString (service.auth == "forward") auth}
                ${service.extra}
                ${lib.optionalString (
                  service.port != null
                ) "reverse_proxy ${service.host}:${toString service.port}"}
              }
            '') (builtins.attrValues config.kibadda.services)
          )}
        '';
      };
    };
}
