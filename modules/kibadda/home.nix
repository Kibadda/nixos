{
  secrets,
  pkgs,
  ...
}:
{
  imports = [
    ../gaming/home.nix
    ../home-office/home.nix
    ../hypr/home.nix
    ../i3/home.nix
    ../nvidia/home.nix
    ../vpn/home.nix
    ../yubikey/home.nix
    ../zsh/home.nix

    ../cursor.nix
    ../direnv.nix
    ../dunst.nix
    ../eza.nix
    ../firefox.nix
    ../font.nix
    ../git.nix
    ../kitty.nix
    ../neovim.nix
    ../pass.nix
    ../ssh.nix
    ../zoxide.nix
  ];

  config = {
    home = {
      username = secrets.base.username;

      homeDirectory = "/home/${secrets.base.username}";

      packages = [ pkgs.kibadda.setup-git-repos ];

      file."intelephense/licence.txt".text = secrets.base.intelephenseLicense;
    };

    xdg.enable = true;
  };
}
