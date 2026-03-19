{
  secrets,
  ...
}:
{
  flake.homeModules.office =
    {
      config,
      pkgs,
      ...
    }:
    {
      kibadda.ssh.hosts = secrets.work.sshHosts;

      home = {
        packages = with pkgs; [
          thunderbird
          sshfs
          bruno
          kibadda.work
          linphone
        ];

        sessionVariables = {
          WORK_DIR = "$HOME/.local/state/work/";
          WORK_URL = secrets.work.timekeeping.url;
          WORK_TOKEN = secrets.work.timekeeping.token;
        };

        file = builtins.listToAttrs (
          builtins.concatMap (key: [
            {
              name = ".ssh/${key}";
              value.text = secrets.work.additionalSshKeys.${key}.private;
            }
            {
              name = ".ssh/${key}.pub";
              value.text = secrets.work.additionalSshKeys.${key}.public;
            }
          ]) (builtins.attrNames secrets.work.additionalSshKeys)
        );
      };

      programs = {
        sftpman = {
          enable = true;
          mounts = secrets.work.sshMounts;
        };

        firefox.profiles.work = {
          id = 1;
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            vimium
            darkreader
            bitwarden
          ];
          settings = {
            "browser.startup.homepage" = "https://in.${secrets.work.domain}";
          };
          search = {
            default = "ddg";
            privateDefault = "ddg";
            force = true;
            engines = {
              "Nix packages" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };

              "Nix options" = {
                urls = [
                  {
                    template = "https://search.nixos.org/options";
                    params = [
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@no" ];
              };

              "NixOS Wiki" = {
                urls = [
                  {
                    template = "https://wiki.nixos.org/w/index.php";
                    params = [
                      {
                        name = "search";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@nw" ];
              };

              "Homemanager options" = {
                urls = [
                  {
                    template = "https://home-manager-options.extranix.com";
                    params = [
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                      {
                        name = "release";
                        value = "master";
                      }
                    ];
                  }
                ];
                icons = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@ho" ];
              };

              "Nix github" = {
                urls = [
                  {
                    template = "https://github.com/search";
                    params = [
                      {
                        name = "type";
                        value = "code";
                      }
                      {
                        name = "q";
                        value = "language:nix {searchTerms}";
                      }
                    ];
                  }
                ];
                icons = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@ng" ];
              };

              google.metaData.hidden = true;
              bing.metaData.hidden = true;
              amazon.metaData.hidden = true;
              ebay.metaData.hidden = true;
              wikipedia.metaData.hidden = true;
            };
          };
          bookmarks = {
            force = true;
            settings = [
              {
                name = "Work";
                bookmarks = [
                  {
                    name = "Pizza";
                    url = "https://mybuks.de/pinocchio-ulm";
                  }
                  {
                    name = "Neocortex";
                    url = "https://in.${secrets.work.domain}";
                  }
                  {
                    name = "Git";
                    url = "https://git.${secrets.work.domain}";
                  }
                ];
              }
            ];
          };
        };
      };
    };

  flake.nixosModules.office = {
    security.pki.certificates = [ secrets.work.certificate ];
  };
}
