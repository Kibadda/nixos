{
  pkgs,
  ...
}:
{
  programs.password-store = {
    enable = false;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.password-store";
    };
  };
}
