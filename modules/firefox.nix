{
  config,
  lib,
  secrets,
  pkgs,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.firefox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.firefox.enable {
    home.sessionVariables = {
      BROWSER = "firefox";
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
      };
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

          "media.eme.enabled" = true;
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
              widget-overflow-fixed-list = [ ];
              toolbar-menubar = [ "menubar-items" ];
              PersonalToolbar = [ "personal-bookmarks" ];
              nav-bar = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "home-button"
                "urlbar-container"
                "downloads-button"
                "unified-extensions-button"
                "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
                "addon_darkreader_org-browser-action"
              ];
              TabsToolbar = [
                "firefox-view-button"
                "tabbrowser-tabs"
                "new-tab-button"
              ];
              unified-extensions-area = [
                "jid1-mnnxcxisbpnsxq_jetpack-browser-action"
                "ublock0_raymondhill_net-browser-action"
                "_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action"
                "gdpr_cavi_au_dk-browser-action"
                "_74145f27-f039-47ce-a470-a662b129930a_-browser-action"
                "firefox_ghostery_com-browser-action"
                "sponsorblocker_ajay_app-browser-action"
                "myallychou_gmail_com-browser-action"
              ];
            };
            currentVersion = 20;
            newElementCount = 3;
          };
        };
      };
      languagePacks = [
        "de"
        "en-US"
      ];
      profiles.${secrets.base.username} = {
        id = 0;
        isDefault = true;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          (buildFirefoxXpiAddon {
            pname = "unhook";
            version = "1.6.7";
            addonId = "myallychou@gmail.com";
            url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-recommended-videos/latest.xpi";
            sha256 = "sha256-u21ouN9IyOzkTkFSeDz+QBp9psJ1F2Nmsvqp6nh0DRU=";
            meta = { platforms = lib.platforms.all; };
          })
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
          bitwarden
        ];
        settings = {
          "browser.startup.homepage" = "https://${secrets.pi.dashboard.domain}";
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
              name = "Nix";
              toolbar = true;
              bookmarks = [
                {
                  name = "Discord";
                  url = "https://discord.com/app";
                }
                {
                  name = "AWS";
                  url = "https://eu-central-1.console.aws.amazon.com/s3/home?region=eu-central-1";
                }
              ];
            }
          ];
        };
      };
    };
  };
}
