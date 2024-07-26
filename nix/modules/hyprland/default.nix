{ pkgs, ... }: {
  programs.hyprland.enable = true;

  environment = {
    systemPackages = with pkgs; [
      wl-clipboard
      grim
      slurp
    ];

    loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };
}
