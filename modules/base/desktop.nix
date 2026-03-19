{
  secrets,
  self,
  ...
}:
{
  flake.homeModules.desktop =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        self.homeModules.base
      ];

      home = {
        packages = with pkgs; [
          nerd-fonts.jetbrains-mono
          font-awesome
        ];
        pointerCursor = {
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
          size = 18;
          gtk.enable = true;
        };
      };

      fonts.fontconfig.enable = true;
    };

  flake.nixosModules.desktop =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        self.nixosModules.base
      ];

      boot = {
        loader = {
          systemd-boot = {
            enable = true;
            configurationLimit = 10;
          };
          efi.canTouchEfiVariables = true;
        };
        binfmt.emulatedSystems = [ "aarch64-linux" ];
      };

      networking.networkmanager.enable = true;

      services.pipewire = {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
      };

      fonts.fontDir.enable = true;

      hardware.bluetooth.enable = true;

      users.users.${secrets.base.username}.extraGroups = [ "networkmanager" ];

      environment.systemPackages = with pkgs; [
        xdg-utils
        spotify
        telegram-desktop
        claude-code
      ];
    };
}
