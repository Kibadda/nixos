{
  lib,
  secrets,
  ...
}:
{
  flake.nixosModules.services = {
    options.kibadda.services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, ... }:
          {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                default = config._module.args.name;
              };
              subdomain = lib.mkOption {
                type = lib.types.str;
                default = config._module.args.name;
              };
              host = lib.mkOption {
                type = lib.types.str;
                default = "localhost";
              };
              port = lib.mkOption {
                type = lib.types.nullOr lib.types.int;
                default = null;
              };
              open = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
              extra = lib.mkOption {
                type = lib.types.str;
                default = "";
              };
              auth = lib.mkOption {
                type = lib.types.enum [
                  "none"
                  "oidc"
                  "forward"
                ];
              };
              policy = lib.mkOption {
                type = lib.types.enum [
                  "one_factor"
                  "two_factor"
                ];
                default = "one_factor";
              };
              oidc = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.submodule {
                    options = {
                      redirect_uris = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                      };
                      method = lib.mkOption {
                        type = lib.types.enum [
                          "basic"
                          "post"
                        ];
                      };
                      claim = lib.mkOption {
                        type = lib.types.nullOr lib.types.attrs;
                        default = null;
                      };
                    };
                  }
                );
                default = null;
              };
              backup = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.submodule {
                    options = {
                      paths = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                      };
                      time = lib.mkOption {
                        type = lib.types.str;
                        default = "01:00";
                      };
                    };
                  }
                );
                default = null;
              };
              backup2 = {
                sync = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                };
                archive = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                };
              };
              url = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
                default = "https://${config.subdomain}.${secrets.pi.domain}";
              };
              description = lib.mkOption {
                type = lib.types.str;
              };
              icon = lib.mkOption {
                type = lib.types.str;
                default = "${config._module.args.name}.svg";
              };
              section = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.enum [
                    "Monitoring"
                    "Tools"
                    "Apps"
                  ]
                );
                default = null;
              };
              widget = lib.mkOption {
                type = lib.types.nullOr lib.types.attrs;
                default = null;
              };
            };
          }
        )
      );
      default = { };
    };
  };
}
