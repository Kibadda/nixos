{
  lib,
  ...
}:
{
  flake.nixosModules.dashboard =
    {
      config,
      ...
    }:
    {
      kibadda.services.dashboard = {
        description = "Dashboard";
        subdomain = "dashboard";
        port = 8082;
        open = true;
        auth = "forward";
      };

      services.homepage-dashboard = {
        enable = true;
        allowedHosts = "${config.kibadda.services.dashboard.hostname}";
        customCSS = ''
          body, html {
            font-family: JetBrainsMono Nerd Font, Helvetica, Arial, sans-serif !important;
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
          color = "zinc";
          target = "_self";
          layout = [
            {
              Links = {
                header = false;
                style = "row";
                columns = 5;
              };
            }
            {
              Apps = {
                header = true;
                style = "column";
              };
            }
            {
              Tools = {
                header = true;
                style = "column";
              };
            }
            {
              Monitoring = {
                header = true;
                style = "row";
                columns = 2;
              };
            }
          ];
          headerStyle = "clean";
          statusStyle = "dot";
          hideVersion = "true";
        };
        services =
          let
            transform =
              services: section:
              lib.concatMap
                (service: [
                  {
                    ${service.description} = {
                      icon = service.icon;
                      href = service.url;
                      siteMonitor = service.url;
                      widget = service.widget;
                    };
                  }
                ])
                (
                  builtins.sort (a: b: a.description < b.description) (
                    builtins.attrValues (
                      lib.filterAttrs (_: service: service.section == section && service.name != "dashboard") services
                    )
                  )
                );
          in
          [
            {
              Monitoring = [
                {
                  FritzBox = {
                    icon = "fritzbox.svg";
                    href = "http://fritz.box";
                    siteMonitor = "http://fritz.box";
                    widget = {
                      type = "fritzbox";
                      url = "http://fritz.box";
                      fields = [
                        "externalIPAddress"
                        "uptime"
                        "down"
                        "up"
                      ];
                    };
                  };
                }
                {
                  Caddy = {
                    icon = "caddy.svg";
                    widget = {
                      type = "caddy";
                      url = "http://localhost:2019";
                    };
                  };
                }
              ]
              ++ (transform config.kibadda.services "Monitoring");
            }
            {
              Apps = transform config.kibadda.services "Apps";
            }
            {
              Tools = transform config.kibadda.services "Tools";
            }
            {
              Links = [
                {
                  Youtube = {
                    icon = "youtube.svg";
                    href = "https://youtube.de";
                  };
                }
                {
                  Kalender = {
                    icon = "google-calendar.svg";
                    href = "https://calendar.google.com";
                  };
                }
                {
                  Email = {
                    icon = "gmail.svg";
                    href = "https://mail.google.com";
                  };
                }
                {
                  Discord = {
                    icon = "discord.svg";
                    href = "https://discord.com/app";
                  };
                }
                {
                  AWS = {
                    icon = "aws.svg";
                    href = "https://eu-central-1.console.aws.amazon.com/s3/home?region=eu-central-1";
                  };
                }
              ];
            }
          ];
      };
    };
}
