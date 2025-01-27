{ meta, pkgs, ... }:
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

    ../chrome.nix
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
      username = meta.username;

      homeDirectory = "/home/${meta.username}";

      sessionVariables = {
        NIXOS_DIR = "$HOME/.dotfiles";
      };

      packages = [ pkgs.kibadda.setup-git-repos ];
    };

    xdg.enable = true;
  };
}
