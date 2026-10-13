{
  secrets,
  ...
}:
{
  flake.homeModules.zsh =
    {
      config,
      pkgs,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        history.path = "${config.xdg.configHome}/zsh/history";
        dotDir = "${config.xdg.configHome}/zsh";
        autosuggestion.enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;

        shellAliases = {
          update = "sudo nixos-rebuild switch --flake .#$(hostname)";
          check = "nix flake check";
          cat = "bat";
        };

        initContent = # bash
          ''
            _kibadda_base_prompt="$PROMPT"

            function _kibadda_set_prompt() {
              local prefix=""
              if [[ -n $SSH_CONNECTION ]]; then
                prefix+="%{$fg_bold[red]%}%m "
              fi
              if [[ -n $IN_NIX_SHELL ]]; then
                prefix+="%{$fg_bold[cyan]%}  "
              fi
              PROMPT="$prefix$_kibadda_base_prompt"
            }

            autoload -Uz add-zsh-hook
            add-zsh-hook precmd _kibadda_set_prompt

            # `nix shell` sets no marker of its own, but the shell it spawns
            # inherits the environment, so export IN_NIX_SHELL for it.
            function nix() {
              if [[ $1 == shell ]]; then
                IN_NIX_SHELL=impure command nix "$@"
              else
                command nix "$@"
              fi
            }

            function switch() {
              NIX_SSHOPTS='-p ${toString secrets.home.sshPort}' nixos-rebuild switch --flake .#$1 --target-host $1 --sudo --ask-sudo-password
            }

            function build() {
              nixos-rebuild build-image --image-variant sd-card --flake .#$1
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
      };
    };

  flake.nixosModules.zsh =
    {
      pkgs,
      ...
    }:
    {
      programs.zsh.enable = true;

      users.users.${secrets.base.username}.shell = pkgs.zsh;

      environment.pathsToLink = [ "/share/zsh" ];
    };
}
