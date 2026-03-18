{
  config,
  pkgs,
  secrets,
  ...
}:
{
  programs.zsh = {
    enable = true;
    history.path = "${config.xdg.dataHome}/zsh/history";

    shellAliases = {
      update = "sudo nixos-rebuild switch --flake .#$(hostname)";
      check = "nix flake check";
      cat = "bat";
    };

    initContent = # bash
      ''
        if echo "$PATH" | grep -qc "/nix/store"; then
          nixshell="%{$fg_bold[cyan]%} "
          PROMPT="$nixshell $PROMPT"
        fi

        if [[ -n $SSH_CONNECTION ]]; then
          hostname="%{$fg_bold[red]%}%m"
          PROMPT="$hostname $PROMPT"
        fi

        function switch() {
          NIX_SSHOPTS='-p ${toString secrets.home.sshPort}' nixos-rebuild switch --flake .#$1 --target-host $1 --sudo --ask-sudo-password
        }

        function build() {
          nix build .#nixosConfigurations.$1.config.system.build.sdImage
        }
      '';

    sessionVariables = {
      TIMER_PRECISION = 2;
      TIMER_FORMAT = "[%d]";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "timer"
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
