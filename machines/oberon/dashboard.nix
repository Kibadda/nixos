{
  secrets,
  config,
  lib,
  ...
}:
let
  cfg = config.home-manager.users.${secrets.base.username}.kibadda;
in
{
  options =
    let
      dashboardService = {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
          };
          icon = lib.mkOption {
            type = lib.types.str;
          };
          description = lib.mkOption {
            type = lib.types.str;
          };
          url = lib.mkOption {
            type = lib.types.str;
          };
        };
      };
    in
    {
      oberon.dashboard = {
        Home = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule dashboardService);
          default = [ ];
        };
        Coding = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule dashboardService);
          default = [ ];
        };
      };
    };

  config = {
    oberon = {
      nginx."${secrets.pi.dashboard.domain}" = {
        restrict-access = true;
        port = 8082;
      };
    };

    services.homepage-dashboard = {
      enable = true;
      environmentFile = builtins.toFile "homepage.env" "HOMEPAGE_ALLOWED_HOSTS=${secrets.pi.dashboard.domain}";
      customCSS = ''
        body, html {
          font-family: ${cfg.font.main.name} Nerd Font, Helvetica, Arial, sans-serif !important;
        }
        .font-medium {
          font-weight: 700 !important;
        }
        .font-light {
          font-weight: 500 !important;
        }
        .font-thin {
          font-weight: 400 !important;
        }
        #information-widgets {
          padding-left: 1.5rem;
          padding-right: 1.5rem;
        }
        div#footer {
          display: none;
        }
        .services-group.basis-full.flex-1.px-1.-my-1 {
          padding-bottom: 3rem;
        };
      '';
      settings = {
        layout = [
          {
            Home = {
              header = true;
              style = "column";
            };
          }
          {
            Coding = {
              header = true;
              style = "column";
            };
          }
          {
            Oberon = {
              header = true;
              style = "column";
            };
          }
          {
            Umbriel = {
              header = true;
              style = "column";
            };
          }
        ];
        headerStyle = "clean";
        statusStyle = "dot";
        hideVersion = "true";
      };
      services =
        let
          piInfo = url: [
            {
              Info = {
                widget = {
                  type = "glances";
                  url = url;
                  metric = "info";
                  chart = false;
                  version = 4;
                };
              };
            }
            {
              "CPU Temp" = {
                widget = {
                  type = "glances";
                  url = url;
                  metric = "sensor:cpu_thermal 0";
                  chart = false;
                  version = 4;
                };
              };
            }
            {
              Processes = {
                widget = {
                  type = "glances";
                  url = url;
                  metric = "process";
                  chart = false;
                  version = 4;
                };
              };
            }
            {
              Network = {
                widget = {
                  type = "glances";
                  url = url;
                  metric = "network:wlan0";
                  chart = false;
                  version = 4;
                };
              };
            }
          ];

          convertServices =
            services:
            builtins.map (conf: {
              ${conf.name} = {
                icon = conf.icon;
                description = conf.description;
                href = conf.url;
                siteMonitor = conf.url;
              };
            }) services;
        in
        [
          {
            Home = convertServices config.oberon.dashboard.Home;
          }
          {
            Coding = convertServices config.oberon.dashboard.Coding;
          }
          {
            Oberon = piInfo "http://localhost:61208";
          }
          {
            Umbriel = piInfo "http://10.0.0.4:61208";
          }
        ];
    };
  };
}
