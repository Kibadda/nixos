{
  secrets,
  ...
}:
{
  flake.homeModules.zsh =
    {
      pkgs,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        history.path = "/home/${secrets.base.username}/.config/zsh/history";
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
              # nix build .#nixosConfigurations.$1.config.system.build.sdImage
              nixos-rebuild build-image --image-variant iso --flake .#$1
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
