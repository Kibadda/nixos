{ pkgs, ... }: {
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/.dotfiles/modules/hyprpaper/wallpaper.png"
      ];
      wallpaper = [
        ",~/.dotfiles/modules/hyprpaper/wallpaper.png"
      ];
    };
  };

  wayland.windowManager.hyprland.settings.exec-once = [
    "${pkgs.hyprpaper}/bin/hyprpaper"
  ];
}
