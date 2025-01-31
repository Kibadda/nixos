{
  meta,
  inputs,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs meta; };
    users.${meta.username} = {
      imports = [
        ../${meta.hostname}/home.nix
      ];

      programs.home-manager.enable = true;

      # It is occasionally necessary for Home Manager to change configuration
      # defaults in a way that is incompatible with stateful data. This could,
      # for example, include switching the default data format or location of a file.
      #
      # The state version indicates which default settings are in effect and
      # will therefore help avoid breaking program configurations. Switching
      # to a higher state version typically requires performing some manual
      # steps, such as data conversion or moving files.
      home.stateVersion = "24.05";
    };
  };
}
