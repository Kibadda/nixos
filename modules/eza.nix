{ meta, ... }: {
  home-manager.users.${meta.username}.programs.eza = {
    enable = true;
    icons = true;
    git = true;
  };
}
