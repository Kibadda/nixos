{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
    chromium
  ];

  programs = {
    hyprland.enable = true;
  };
}
