{
  secrets,
  pkgs,
  lib,
  config,
  ...
}:
let
  format = pkgs.formats.yaml { };
  usersFile = format.generate "users.yml" secrets.pi.authelia.users;
in
{
  options = {
    oberon.authelia = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            id = lib.mkOption {
              type = lib.types.str;
            };
            secret = lib.mkOption {
              type = lib.types.str;
            };
            redirect_uris = lib.mkOption {
              type = lib.types.listOf lib.types.str;
            };
            scopes = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [
                "openid"
                "profile"
                "email"
              ];
            };
            auth_method = lib.mkOption {
              type = lib.types.str;
              default = "basic";
            };
          };
        }
      );
    };
  };

  config = {
    services = {
      nginx.virtualHosts.${secrets.pi.authelia.domain} = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/".extraConfig = ''
            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
            add_header X-Content-Type-Options nosniff;
            add_header X-Frame-Options "SAMEORIGIN";
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
            add_header X-Download-Options noopen;
            add_header X-Permitted-Cross-Domain-Policies none;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_cache_bypass $http_upgrade;

            proxy_pass http://127.0.0.1:9091;
            proxy_intercept_errors on;
            if ($request_method !~ ^(POST)$){
                error_page 401 = /error/401;
                error_page 403 = /error/403;
                error_page 404 = /error/404;
            }
          '';
          "/api/verify".extraConfig = ''
            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
            add_header X-Content-Type-Options nosniff;
            add_header X-Frame-Options "SAMEORIGIN";
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
            add_header X-Download-Options noopen;
            add_header X-Permitted-Cross-Domain-Policies none;

            proxy_set_header Host $http_x_forwarded_host;
            proxy_pass http://127.0.0.1:9091;
          '';
        };
      };

      authelia.instances.main = {
        enable = true;
        settings = {
          theme = "auto";
          authentication_backend = {
            file = {
              path = "/etc/authelia/users.yml";
              password = {
                algorithm = "argon2";
                argon2 = {
                  variant = "argon2id";
                  iterations = 3;
                  memory = 65536;
                  parallelism = 4;
                  key_length = 32;
                };
              };
            };
          };
          access_control = {
            default_policy = "deny";
            rules = [
              {
                domain = "*.${secrets.pi.domains.dev}";
                policy = "one_factor";
              }
              {
                domain = "*.${secrets.pi.domains.family}";
                policy = "one_factor";
              }
            ];
          };
          session = {
            secret = secrets.pi.authelia.sessionSecret;
            cookies = [
              {
                domain = secrets.pi.domains.dev;
                authelia_url = "https://${secrets.pi.authelia.domain}";
              }
            ];
          };
          storage = {
            postgres = {
              address = "unix:///run/postgresql";
              username = "authelia-main";
              database = "authelia-main";
            };
          };
          notifier = {
            filesystem = {
              filename = "/var/lib/authelia-main/notifications.txt";
            };
          };
          identity_providers = {
            oidc = {
              hmac_secret = secrets.pi.authelia.oidc.hmac;
              jwks = [
                {
                  key = secrets.pi.authelia.oidc.key;
                }
              ];
              clients = builtins.attrValues (
                builtins.mapAttrs (id: conf: {
                  client_id = id;
                  client_secret = conf.secret;
                  redirect_uris = conf.redirect_uris;
                  scopes = conf.scopes;
                  response_types = [ "code" ];
                  grant_types = [ "authorization_code" ];
                  public = false;
                  authorization_policy = "one_factor";
                  token_endpoint_auth_method = "client_secret_${conf.auth_method}";
                }) config.oberon.authelia
              );
            };
          };
        };
        secrets = {
          jwtSecretFile = pkgs.writeText "jwtSecret" secrets.pi.authelia.jwtSecret;
          storageEncryptionKeyFile = pkgs.writeText "encryptionSecret" secrets.pi.authelia.encryptionSecret;
        };
      };

      postgresql = {
        ensureDatabases = [ "authelia-main" ];
        ensureUsers = [
          {
            name = "authelia-main";
            ensureDBOwnership = true;
          }
        ];
      };
    };

    environment = {
      systemPackages = [ pkgs.authelia ];
      etc."authelia/users.yml".source = usersFile;
    };
  };
}
