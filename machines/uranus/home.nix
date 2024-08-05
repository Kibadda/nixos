{ pkgs, ... }: {
  imports = [
    ../../modules/chrome.nix
  ];

  home.packages = with pkgs; [
    chiaki
  ];
}
