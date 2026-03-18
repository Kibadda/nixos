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
  lib = lib;
  name = "magic-tournament";
  repository = "Tobael/tournament";
  port = 8081;
  restrict-access = false;
  time = "04:30";
  secrets = secrets.pi.magic-tournament // {
    username = secrets.base.username;
  };
  description = "Magic Tournaments";
}
