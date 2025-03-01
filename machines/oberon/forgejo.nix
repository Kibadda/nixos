{
  meta,
  pkgs,
  ...
}:
{
  oberon = {
    nginx."${meta.pi.forgejo.domain}" = {
      restrict-access = false;
      port = 3050;
    };

    backup.forgejo = {
      path = meta.pi.forgejo.dir;
      time = "03:00";
      exclude = [
        "tmp/**"
        "log/**"
      ];
    };
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
          BUILTIN_SSH_SERVER_USER = "git";
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
          SHOW_USER_EMAIL = false;
        };
        actions = {
          ENABLED = true;
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
        default = {
          enable = true;
          name = meta.hostname;
          url = "https://${meta.pi.forgejo.domain}";
          token = meta.pi.forgejo.actions-runner-token;
          labels = [
            "runner:docker://ghcr.io/catthehacker/ubuntu:runner-latest"
            "act:docker://ghcr.io/catthehacker/ubuntu:act-latest"
          ];
        };
      };
    };
  };

  virtualisation.docker.enable = true;
}
