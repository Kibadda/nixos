{ pkgs, ... }: let 
  name = "Bibata-Modern-Classic";
in {
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = name;
  };

  wayland.windowManager.hyprland.settings.exec-once = [
    "hyprctl setcursor \"${name}\" 24"
  ];
}
