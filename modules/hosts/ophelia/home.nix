{
  ...
}:
{
  imports = [
    ../../modules/kibadda/home.nix
  ];

  kibadda = {
    firefox.enable = true;

    kitty.size = 18;

    yubikey.enable = false;

    gnome.enable = true;
  };
}
