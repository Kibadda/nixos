{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixos";
      };

      packages.php = pkgs.buildEnv {
        name = "php";
        paths = with pkgs; [
          (php84.withExtensions ({ enabled, all, ... }: enabled ++ [ all.apcu ]))
          php84Packages.composer
          mariadb
        ];
      };
    };
}
