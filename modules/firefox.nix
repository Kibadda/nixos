{ config, lib, ... }: let
  cfg = config.kibadda;
in {
  options = {
    kibadda.firefox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      default = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.firefox.enable {
    home.sessionVariables = lib.mkIf (cfg.firefox.default || !cfg.chrome.enable) {
      BROWSER = "firefox";
    };

    programs.firefox = {
      enable = true;
      languagePacks = [ "de" "en-US" ];
      profiles.default = {
        isDefault = true;
        search = {
          default = "DuckDuckGo";
          force = true;
          engines = {
            "Github Nix" = {
              urls = [
                {
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}+lang:nix";
                    }
                    {
                      name = "type";
                      value = "code";
                    }
                  ];
                }
              ];
              definedAliases = [ "@gn" ];
            };

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
              definedAliases = [ "@no" ];
            };
          };
        };
        bookmarks = [
          {
            name = "Nix";
            toolbar = true;
            bookmarks = [
              {
                name = "NixOs Search";
                url = "https://search.nixos.org";
              }
              {
                name = "Homemanager Search";
                url = "https://nix-community.github.io/home-manager/options.xhtml";
              }
              {
                name = "wiki";
                url = "https://wiki.nixos.org";
              }
            ];
          }
        ];
      };
      policies = {
        DisablePocket = true;
        DisableFirefoxStudios = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = true;
        DontCheckDefaultBrowser = true;
        OfferToSaveLogins = false;
        NoDefaultBookmarks = true;
      };
    };
  };
}
