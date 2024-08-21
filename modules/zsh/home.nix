{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    history.path = "${config.xdg.dataHome}/zsh/history";

    shellAliases = {
      update = "sudo nixos-rebuild switch --flake $NIXOS_DIR#$(hostname)";
      check = "nix flake check";
      cat = "bat";
      nvimdev = "nix run $NIXVIM_DIR#nvim-dev";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git" "sudo"
      ];
      theme = "robbyrussell";
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];
  };
}
