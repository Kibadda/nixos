{ pkgs, ... }: {
  home.packages = with pkgs; [
    hyprshade
  ];

  home.file.".config/hypr/hyprshade.toml" = {
    source = ./hyprshade.toml;
  };

  wayland.windowManager.hyprland.settings.exec = [
    "${pkgs.hyprshade}/bin/hyprshade auto"
  ];
}
