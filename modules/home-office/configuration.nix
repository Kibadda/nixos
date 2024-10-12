{ lib, config, meta, ... }: let
  cfg = config.home-manager.users.${meta.username}.home-office;
in {
  config = lib.mkIf cfg.enable {
    networking.wg-quick.interfaces.work = meta.work.vpn;
  };
}
