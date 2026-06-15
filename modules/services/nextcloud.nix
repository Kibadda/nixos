{
  secrets,
  ...
}:
{
  flake.nixosModules.nextcloud =
    {
      config,
      pkgs,
      ...
    }:
    {
      kibadda.services.nextcloud = {
        description = "Cloud";
        subdomain = "cloud";
        open = true;
        auth = "oidc";
        oidc = {
          redirect_uris = [
            "${config.kibadda.services.nextcloud.url}/index.php/apps/oidc_login/oidc"
          ];
          method = "basic";
        };
        extra = ''
          root * ${config.services.nextcloud.finalPackage}
          php_fastcgi unix/${config.services.phpfpm.pools.nextcloud.socket}
          file_server
        '';
        backup = {
          paths = [ "/mnt/nextcloud" ];
          time = "03:00";
        };
        backup2 = {
          archive = [ "/mnt/nextcloud/data/nextcloud.db" ];
          sync = [ "/mnt/nextcloud/data/michael" ];
        };
        section = "Apps";
      };

      services = {
        nextcloud = {
          enable = true;
          package = pkgs.nextcloud33;
          hostName = "cloud.${secrets.pi.domain}";
          database.createLocally = true;
          home = "/mnt/nextcloud";
          config = {
            dbtype = "sqlite";
            adminpassFile = "/etc/nextcloud/adminpass";
          };
          extraApps = {
            oidc_login = pkgs.nextcloud33Packages.apps.oidc_login;
            calendar = pkgs.nextcloud33Packages.apps.calendar;
          };
          settings = {
            overwriteprotocol = "https";
            default_language = "de";
            default_locale = "de_DE";
            default_phone_region = "DE";
            allow_user_to_change_display_name = false;
            lost_password_link = "disabled";
            oidc_login_provider_url = config.kibadda.services.authelia.url;
            oidc_login_client_id = "nextcloud";
            oidc_login_client_secret = secrets.pi.authelia.oidc.nextcloud;
            oidc_login_auto_redirect = true;
            oidc_login_button_text = "Authelia";
            oidc_login_hide_password_form = true;
            oidc_login_attributes = {
              id = "preferred_username";
              name = "name";
              mail = "email";
              groups = "groups";
            };
            oidc_login_default_group = "oidc";
            oidc_login_scope = "openid profile email groups";
            oidc_login_disable_registration = false;
            oidc_create_groups = true;
          };
        };

        phpfpm.pools.nextcloud.settings = {
          "listen.owner" = config.services.caddy.user;
          "listen.group" = config.services.caddy.group;
        };

        nginx.enable = false;
      };

      environment.etc = {
        "nextcloud/adminpass".text = secrets.pi.nextcloud.password;
      };
    };
}
