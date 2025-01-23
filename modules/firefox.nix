{ config, lib, meta, pkgs, ... }: let
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
      policies = {
        DontCheckDefaultBrowser = true;
        DisableTelemetry = true;
        DisableFirefoxStudios = true;
        DisablePocket = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxAccounts = true;

        DisplayBookmarksToolbar = true;
        DisplayMenuBar = "never";

        OverrideFirstRunPage = "";
        PictureInPicture.Enabled = false;
        PromptForDownloadLocation = false;

        HardwareAcceleration = true;
        TranslateEnabled = true;

        Homepage.StartPage = "previous-session";

        UserMessaging = {
          UrlbarInterventions = false;
          SkipOnboarding = true;
        };

        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
        };

        EnableTrackingProtection = {
          Value = true;
          Cryptomining = true;
          Fingerprinting = true;
        };

        FirefoxHome = {
          Search = true;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
        };

        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;

        Preferences = {
          "browser.urlbar.suggest.searches" = true;
          "browser.urlbar.shortcuts.bookmarks" = false;
          "browser.urlbar.shortcuts.history" = false;
          "browser.urlbar.shortcuts.tabs" = false;

          "browser.tabs.tabMinWidth" = 75;

          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.placeholderName.private" = "DuckDuckGo";

          "browser.aboutConfig.showWarning" = false;
          "browser.warnOnQuitShortcut" = false;

          "browser.tabs.loadInBackground" = true;

          "media.ffmpeg.vaapi.enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "gfx.webrender.all" = true;

          "browser.in-content.dark-mode" = true;
          "ui.systemUsesDarkTheme" = true;

          "extensions.autoDisableScopes" = 0;
          "extensions.update.enabled" = false;
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;

          "browser.uiCustomization.state" = builtins.toJSON {
            placements = {
              widget-overflow-fixed-list = [];
              toolbar-menubar = [ "menubar-items" ];
              PersonalToolbar = [ "personal-bookmarks" ];
              nav-bar = [
                "back-button"
                "forward-button"
                "urlbar-container"
                "downloads-button"
                "unified-extensions-button"
              ];
              TabsToolbar = [
                "firefox-view-button"
                "tabbrowser-tabs"
                "new-tab-button"
              ];
              unified-extensions-area = [];
            };
            currentVersion = 20;
            newElementCount = 3;
          };
        };
      };
      languagePacks = [ "de" "en-US" ];
      profiles.${meta.username} = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          vimium
          darkreader
          sponsorblock
          duckduckgo-privacy-essentials
          ghostery
          clearurls
          consent-o-matic
          privacy-badger
          decentraleyes
        ];
        # settings = {
        #   "extensions.autoDisableScopes" = 0;
        #   "browser.theme.content-theme" = 0;
        #   "browser.theme.toolbar-theme" = 0;
        # };
        search = {
          default = "DuckDuckGo";
          privateDefault = "DuckDuckGo";
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

            "Google".metaData.hidden = true;
            "Bing".metaData.hidden = true;
            "Amazon.com".metaData.hidden = true;
            "eBay".metaData.hidden = true;
            "Wikipedia (en)".metaData.hidden = true;
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
    };
  };
}
