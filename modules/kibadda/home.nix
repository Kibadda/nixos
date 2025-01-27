{ meta, ... }:
{
  imports = [
    ../hypr/home.nix
    ../i3/home.nix
    ../zsh/home.nix
    ../yubikey/home.nix
    ../nvidia/home.nix
    ../home-office/home.nix
    ../git.nix
    ../kitty.nix
    ../dunst.nix
    ../eza.nix
    ../pass.nix
    ../direnv.nix
    ../ssh.nix
    ../zoxide.nix
    ../neovim.nix
    ../firefox.nix
    ../chrome.nix
    ../font.nix
    ../cursor.nix
  ];

  config = {
    home = {
      username = meta.username;

      homeDirectory = "/home/${meta.username}";

      sessionVariables = {
        NIXOS_DIR = "$HOME/.dotfiles";
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];

      file.".local/bin/fetch-repositories" = {
        executable = true;
        source = ../../bin/fetch-repositories.sh;
      };
    };

    xdg.enable = true;
  };
}
