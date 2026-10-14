{
  flake.nixosModules.hyprland = {
    programs.hyprland.enable = true;

    environment.loginShellInit = # bash
      ''
        if [ -z DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec start-hyprland
        fi
      '';
  };

  flake.homeModules.hyprland =
    {
      pkgs,
      ...
    }:
    let
      path = ".config/hyprpaper/wallpaper.jpg";
    in
    {
      home = {
        packages = with pkgs; [
          grim
          slurp
          wl-clipboard
          brightnessctl
          playerctl
        ];

        file.${path}.source = ../../wallpapers/windmill.jpg;
      };

      programs = {
        satty = {
          enable = true;
          settings = {
            general = {
              fullscreen = false;
              output-filename = "~/Pictures/Screenshots/%Y-%m-%d_%H:%M:%S.png";
            };
          };
        };
      };

      services = {
        hyprlauncher = {
          enable = true;
        };

        hyprpaper = {
          enable = true;
          settings = {
            wallpaper = [
              {
                monitor = "eDP-1";
                path = path;
              }
            ];
          };
        };

        hyprpolkitagent = {
          enable = true;
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        extraConfig = builtins.readFile ./hyprland.lua;
      };
    };
}
