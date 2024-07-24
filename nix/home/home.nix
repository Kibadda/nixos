{ inputs, config, pkgs, meta, ... }: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in {
  imports = [
    ../machines/${meta.hostname}/home.nix
  ];

  programs.home-manager.enable = true;

  xdg.enable = true;

  xdg.configFile.nvim.source = mkOutOfStoreSymlink "/home/${meta.username}/.dotfiles/.config/nvim";
  xdg.dataFile.password-store.source = mkOutOfStoreSymlink "/home/${meta.username}/.password-store";

  home.stateVersion = "24.05";

  programs = {
    zsh = (import ./zsh.nix { inherit config pkgs; });
    neovim = (import ./neovim.nix { inherit config pkgs; });
    git = (import ./git.nix { inherit config pkgs meta; });
    gpg = (import ./gpg.nix { inherit config pkgs; });
    password-store = (import ./pass.nix { inherit config pkgs; });
    kitty = (import ./kitty.nix { inherit config pkgs; });
  };
}
