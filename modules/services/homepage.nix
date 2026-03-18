{
  secrets,
  pkgs,
  lib,
  ...
}:
let
  laravel = import ./laravel.nix;
in
laravel {
  pkgs = pkgs;
  php = pkgs.php.buildEnv {
    extraConfig = "upload_max_filesize = 8M";
  };
  lib = lib;
  name = "homepage";
  repository = "Kibadda/homepage";
  port = 8080;
  restrict-access = true;
  time = "04:00";
  secrets = secrets.pi.homepage // {
    username = secrets.base.username;
  };
  description = "Erinnerungen";
}
