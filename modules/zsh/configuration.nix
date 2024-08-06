{ meta, pkgs, ... }: {
  programs.zsh.enable = true;

  users.users.${meta.username}.shell = pkgs.zsh;
}
