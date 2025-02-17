{
  meta,
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
          };
        }
      );
      default = { };
    };
  };

  config = {
    security.acme = {
      acceptTerms = true;
      defaults.email = meta.email;
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;

      virtualHosts = builtins.mapAttrs (domain: conf: {
        enableACME = conf.ssl;
        forceSSL = conf.ssl;
        extraConfig = if conf.restrict-access then meta.pi.ip-whitelist else "";
        locations."/".proxyPass = "http://localhost:${toString conf.port}";
      }) config.oberon.nginx;
    };
  };
}
