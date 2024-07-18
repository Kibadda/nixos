{ inputs, config, pkgs, ... }: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  imports = [
    ./ags.nix
  ];

  programs.home-manager.enable = true;

  home.username = "michael";
  home.homeDirectory = "/home/michael";
  xdg.enable = true;

  xdg.configFile.nvim.source = mkOutOfStoreSymlink "/home/michael/.dotfiles/.config/nvim";
  xdg.dataFile.password-store.source = mkOutOfStoreSymlink "/home/michael/.password-store";

  home.stateVersion = "23.11";

  programs = {
    zsh = (import ./zsh.nix { inherit config pkgs; });
    neovim = (import ./neovim.nix { inherit config pkgs; });
    git = (import ./git.nix { inherit config pkgs; });
    gpg = (import ./gpg.nix { inherit config pkgs; });
    password-store = (import ./pass.nix { inherit config pkgs; });
  };

  wayland.windowManager = {
    hyprland = (import ./hyprland.nix { inherit pkgs; });
  };
}
