{
  inputs,
  ...
}:
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];
}
