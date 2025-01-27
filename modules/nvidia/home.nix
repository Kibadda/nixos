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
    kibadda.nvidia = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.nvidia.enable {
    wayland.windowManager.hyprland.settings = lib.mkIf cfg.hypr.enable {
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];

      cursor.no_hardware_cursors = true;
    };
  };
}
