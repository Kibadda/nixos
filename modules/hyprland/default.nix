{ inputs, pkgs, ... }: {
  programs.hyprland.enable = true;

  environment = {
    systemPackages = with pkgs; [
      wl-clipboard
      grim
      slurp
      inputs.powermenu.defaultPackage.${pkgs.system}
      inputs.dmenu.defaultPackage.${pkgs.system}
    ];

    loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };
}
