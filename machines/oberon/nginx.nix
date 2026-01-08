{
  secrets,
  config,
  lib,
  ...
}:
{
  options = {
    oberon.nginx = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            ssl = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };
            restrict-access = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            port = lib.mkOption {
              type = lib.types.int;
            };
            host = lib.mkOption {
              type = lib.types.str;
              default = "localhost";
            };
            websockets = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            extraConfig = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
          };
        }
      );
      default = { };
    };
  };

  config = {
    security.acme = {
      acceptTerms = true;
      defaults.email = secrets.base.email;
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;

      virtualHosts = builtins.mapAttrs (domain: conf: {
        enableACME = conf.ssl;
        forceSSL = conf.ssl;
        extraConfig = builtins.concatStringsSep "\n" [
          (
            if conf.restrict-access then
              ''
                allow ${secrets.pi.ip};
                deny all;
              ''
            else
              ""
          )
          conf.extraConfig
        ];
        locations."/".proxyPass = "http://${conf.host}:${toString conf.port}";
        locations."/".proxyWebsockets = conf.websockets;
      }) config.oberon.nginx;
    };
  };
}
