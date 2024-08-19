{ config, ... }: let
  cfg = config.kibadda;
in {
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = cfg.pass;
    };
  };
}
