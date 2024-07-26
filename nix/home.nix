{ inputs, config, pkgs, meta, ... }: {
  imports = [
    ./machines/${meta.hostname}/home.nix
  ];

  home = {
    username = meta.username;
    homeDirectory = "/home/${meta.username}";
  };

  programs.home-manager.enable = true;

  xdg.enable = true;

  # move these to modules?
  programs = {
    zsh = (import ./home/zsh.nix { inherit config pkgs; });
    neovim = (import ./home/neovim.nix { inherit config pkgs; });
    git = (import ./home/git.nix { inherit config pkgs meta; });
    gpg = (import ./home/gpg.nix { inherit config pkgs; });
    password-store = (import ./home/pass.nix { inherit config pkgs; });
    kitty = (import ./home/kitty.nix { inherit config pkgs; });
  };

  # It is occasionally necessary for Home Manager to change configuration
  # defaults in a way that is incompatible with stateful data. This could,
  # for example, include switching the default data format or location of a file.
  #
  # The state version indicates which default settings are in effect and
  # will therefore help avoid breaking program configurations. Switching
  # to a higher state version typically requires performing some manual
  # steps, such as data conversion or moving files.
  home.stateVersion = "24.05";
}
