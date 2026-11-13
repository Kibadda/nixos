{
  lib,
  secrets,
  ...
}:
{
  flake.nixosModules.ntfy =
    {
      config,
      ...
    }:
    let
      dir = "/mnt/ntfy";
    in
    {
      kibadda.services.ntfy = {
        description = "Push";
        subdomain = "push";
        port = 2586;
        auth = "none";
        section = "Apps";
      };

      services.ntfy-sh = {
        enable = true;
        user = "ntfy";
        group = "ntfy";
        settings = {
          base-url = config.kibadda.services.ntfy.url;
          behind-proxy = true;
          listen-http = "127.0.0.1:2586";
          auth-file = "${dir}/user.db";
          auth-default-access = "deny-all";
          auth-users = secrets.pi.ntfy.users;
          auth-access = secrets.pi.ntfy.access;
          access-tokens = secrets.pi.ntfy.tokens;
          attachment-cache-dir = "${dir}/attachments";
          cache-file = "${dir}/cache-file.db";
        };
      };

      users = {
        groups.ntfy = { };

        users.ntfy = {
          isSystemUser = true;
          group = "ntfy";
        };
      };

      systemd = {
        services.ntfy-sh.serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "ntfy";
        };

        tmpfiles.rules = [
          "d ${dir} 0755 ntfy ntfy -"
          "d ${dir}/attachments 0755 ntfy ntfy -"
        ];
      };
    };
}
