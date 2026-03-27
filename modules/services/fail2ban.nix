{
  secrets,
  ...
}:
{
  flake.nixosModules.fail2ban = {
    services.fail2ban = {
      enable = true;
      ignoreIP = [
        secrets.pi.ip
        "10.0.0.0/24"
      ];
      bantime = "1h";
    };
  };
}
