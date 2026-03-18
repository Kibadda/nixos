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
