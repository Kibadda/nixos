{
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.niri =
    {
      pkgs,
      ...
    }:
    let
      noctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;

        settings = { };
      };

      niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;

        settings = {
          spawn-at-startup = [
            (lib.getExe noctalia)
          ];

          input = {
            keyboard = {
              xkb = {
                layout = "de";
                options = "caps:swapescape";
              };
            };
          };

          layout.gaps = 5;

          binds = {
            "Mod+Return".spawn-sh = "kitty";
          };
        };
      };
    in
    {
      programs.niri = {
        enable = true;
        package = lib.getExe niri;
      };
    };
}
