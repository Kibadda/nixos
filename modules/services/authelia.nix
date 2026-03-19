{
  lib,
  secrets,
  ...
}:
{
  flake.nixosModules.authelia =
    {
      config,
      pkgs,
      ...
    }:
    let
      domain = secrets.pi.domain;
    in
    {
      # https://github.com/bjackman/boxen/blob/master/nixos_modules/iap.nix
      services.authelia.instances.main = {
        enable = true;

        secrets = {
          jwtSecretFile = pkgs.writeText "jwtSecret" secrets.pi.authelia.jwtSecret;
          storageEncryptionKeyFile = pkgs.writeText "storageEncryptionKey" secrets.pi.authelia.storageEncryptionKey;
          sessionSecretFile = pkgs.writeText "sessionSecret" secrets.pi.authelia.sessionSecret;
          oidcHmacSecretFile = pkgs.writeText "oidcHmacSecret" secrets.pi.authelia.oidcHmacSecret;
          oidcIssuerPrivateKeyFile = pkgs.writeText "oidcIssuerPrivateKey" secrets.pi.authelia.oidcIssuerPrivateKey;
        };

        settings = {
          authentication_backend = {
            password_reset.disable = true;
            file.path = "/etc/authelia/users.yml";
          };

          storage.local.path = "/var/lib/authelia-main/db.sqlite3";

          access_control = {
            default_policy = "deny";
            rules = [
              {
                domain = "dashboard.${domain}";
                policy = "one_factor";
              }
            ]
            ++ lib.concatMap (
              service:
              lib.optional (service.auth != "none") {
                domain = [ "${service.subdomain}.${domain}" ];
                policy = if service.auth == "oidc" then "bypass" else "one_factor";
              }
            ) (builtins.attrValues config.kibadda.services);
          };

          session = {
            name = "session";
            cookies = [
              {
                domain = domain;
                authelia_url = "https://sso.${domain}";
              }
            ];
          };

          notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";

          identity_providers.oidc = {
            clients = lib.concatMap (
              service:
              lib.optional (service.auth == "oidc") {
                client_id = service.name;
                client_secret = secrets.pi.authelia.oidc.${service.name};
                redirect_uris = service.oidc.redirect_uris;
                scopes = [
                  "openid"
                  "profile"
                  "email"
                  "groups"
                ];
                response_types = [ "code" ];
                grant_types = [ "authorization_code" ];
                public = false;
                authorization_policy = "one_factor";
                token_endpoint_auth_method = "client_secret_${service.oidc.method}";
                consent_mode = "implicit";
                claims_policy = lib.mkIf (service.oidc.claim != null) service.name;
              }
            ) (builtins.attrValues config.kibadda.services);
            claims_policies = builtins.mapAttrs (name: service: service.oidc.claim) (
              lib.filterAttrs (
                _: service: service.auth == "oidc" && service.oidc.claim != null
              ) config.kibadda.services
            );
          };
        };
      };

      environment = {
        systemPackages = [ pkgs.authelia ];
        etc = {
          "authelia/users.yml".source =
            let
              format = pkgs.formats.yaml { };
              usersFile = format.generate "users.yml" secrets.pi.authelia.users;
            in
            usersFile;
        };
      };
    };
}
