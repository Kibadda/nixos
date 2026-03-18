{
  secrets,
  pkgs,
  ...
}:
{
  programs.zsh.enable = true;

  users.users.${secrets.base.username}.shell = pkgs.zsh;
}
