{ inputs, config, pkgs, meta, ... }: {
  home = {
    username = meta.username;
    homeDirectory = "/home/${meta.username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

  xdg.enable = true;

  # move theses to modules?
  programs = {
    zsh = (import ./zsh.nix { inherit config pkgs; });
    neovim = (import ./neovim.nix { inherit config pkgs; });
    git = (import ./git.nix { inherit config pkgs meta; });
    gpg = (import ./gpg.nix { inherit config pkgs; });
    password-store = (import ./pass.nix { inherit config pkgs; });
    kitty = (import ./kitty.nix { inherit config pkgs; });
  };
}
