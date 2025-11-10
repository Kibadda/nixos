let
  importPackages =
    pkgs: list:
    builtins.listToAttrs (
      builtins.map (name: {
        inherit name;
        value = import ./${name}.nix { inherit pkgs; };
      }) list
    );
in
{
  overlays.default = final: prev: {
    kibadda =
      (prev.kibadda or { })
      // importPackages final [
        "spotify-indicator"
        "weather-indicator"
        "yubikey-indicator"
        "screenshot"
        "home"
        "work"
        "setup-git-repos"
        "ophelia-landscape-toggle"
        "nvimupdate"
      ];
  };
}
