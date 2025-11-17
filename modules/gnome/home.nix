{
  lib,
  ...
}:
{
  options = {
    kibadda.gnome = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };
}
