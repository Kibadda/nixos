{
  lib,
  config,
  ...
}:
let
  cfg = config.kibadda;
in
{
  options = {
    kibadda.gnome = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
      };

      custom-keybindings = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
              };

              command = lib.mkOption {
                type = lib.types.str;
              };

              binding = lib.mkOption {
                type = lib.types.str;
              };
            };
          }
        );
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.gnome.enable {
    kibadda.gnome.custom-keybindings = [
      {
        name = "kitty";
        command = "kitty";
        binding = "<Super>Return";
      }
      {
        name = "firefox";
        command = "firefox";
        binding = "<Super>B";
      }
      {
        name = "private firefox";
        command = "firefox --private-window";
        binding = "<Shift><Super>B";
      }
    ];
  };
}
