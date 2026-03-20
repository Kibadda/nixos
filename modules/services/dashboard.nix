{
  lib,
  secrets,
  ...
}:
{
  flake.nixosModules.dashboard =
    {
      config,
      ...
    }:
    {
      services.homepage-dashboard = {
        enable = true;
        allowedHosts = "dashboard.${secrets.pi.domain}";
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
          layout = [
            {
              Services = {
                header = true;
                style = "column";
              };
            }
            {
              Links = {
                header = true;
                style = "column";
              };
            }
          ];
          headerStyle = "clean";
          statusStyle = "dot";
          hideVersion = "true";
        };
        services = [
          {
            Services = lib.concatMap (service: [
              {
                ${service.description} = {
                  icon = service.icon;
                  href = service.url;
                  siteMonitor = service.url;
                };
              }
            ]) (builtins.attrValues config.kibadda.services);
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
