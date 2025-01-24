{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.chrome = {
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

  config = lib.mkIf cfg.chrome.enable {
    home = {
      packages = [
        pkgs.google-chrome
      ];

      sessionVariables = lib.mkIf (cfg.chrome.default || !cfg.firefox.enable) {
        BROWSER = "google-chrome-stable";
      };
    };
  };
}
