{
  lib,
  config,
  secrets,
  ...
}:
let
  cfg = config.home-manager.users.${secrets.base.username}.kibadda;
in
{
  config = lib.mkIf cfg.office.enable {
    security.pki.certificates = [ secrets.work.certificate ];
  };
}
