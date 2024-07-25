{ pkgs, ... }: {
  imports = [
    # this is important
    ../../configuration.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      wl-clipboard
      grim
      slurp
      chromium
    ];

    loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland
      fi
    '';
  };

  programs = {
    hyprland.enable = true;
  };
}
