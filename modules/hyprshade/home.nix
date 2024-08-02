{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      hyprshade
    ];

    file.".config/hypr/hyprshade.toml" = {
      source = ./hyprshade.toml;
    };
  };

  wayland.windowManager.hyprland.settings.exec = [
    "${pkgs.hyprshade}/bin/hyprshade auto"
  ];
}
