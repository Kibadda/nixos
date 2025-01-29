{
  meta,
  ...
}:
{
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
  users.users.${meta.username}.extraGroups = [ "networkmanager" ];
}
