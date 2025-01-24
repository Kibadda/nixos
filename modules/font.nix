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
    kibadda.font = {
      main = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "JetBrainsMono";
        };

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.nerd-fonts.jetbrains-mono;
        };
      };

      additional = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ pkgs.font-awesome ];
      };
    };
  };

  config = {
    fonts.fontconfig.enable = true;

    home.packages = [ cfg.font.main.package ] ++ cfg.font.additional;
  };
}
