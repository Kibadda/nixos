{
  secrets,
  ...
}:
{
  flake.nixosModules.fail2ban = {
    services.fail2ban = {
      enable = true;
      ignoreIP = [ secrets.pi.ip ];
      bantime = "1h";
    };
  };
}
