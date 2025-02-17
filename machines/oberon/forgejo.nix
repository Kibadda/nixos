{
  meta,
  pkgs,
  ...
}:
{
  oberon.nginx."${meta.pi.forgejo.domain}" = {
    restrict-access = false;
    port = 3050;
  };

  services = {
    forgejo = {
      enable = true;
      lfs.enable = true;
      package = pkgs.forgejo;
      settings = {
        DEFAULT = {
          APP_NAME = "Git";
        };
        "repository.pull-request" = {
          DEFAULT_MERGE_STYLE = "rebase";
        };
        server = {
          DOMAIN = meta.pi.forgejo.domain;
          ROOT_URL = "https://${meta.pi.forgejo.domain}/";
          HTTP_PORT = 3050;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        other = {
          SHOW_FOOTER_VERSION = false;
          SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
          SHOW_FOOTER_POWERED_BY = false;
          ENABLE_FEED = false;
        };
        ui = {
          DEFAULT_THEME = "forgejo-dark";
        };
        actions = {
          DEFAULT_ACTIONS_URL = "github";
        };
      };
      database = {
        type = "postgres";
        passwordFile = pkgs.writeText "dbPassword" meta.pi.forgejo.db-password;
      };
      stateDir = meta.pi.forgejo.dir;
    };

    gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances = {
        runner = {
          enable = true;
          name = meta.hostname;
          url = "https://${meta.pi.forgejo.domain}";
          token = meta.pi.forgejo.actions-runner-token;
          labels = [
            "native:host"
          ];
        };
      };
    };
  };
}
