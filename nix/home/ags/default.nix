{ inputs, pkgs, ... }: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    bun
    dart-sass
    fd
    hyprpicker
  ];

  programs.ags = {
    enable = true;
    configDir = ./config;
  };
}
