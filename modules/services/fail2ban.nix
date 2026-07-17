{
  flake.nixosModules.fail2ban = {
    services.fail2ban = {
      enable = true;
      ignoreIP = [
        "10.0.0.0/24"
      ];
      maxretry = 3;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        factor = "4";
        maxtime = "168h";
      };
    };
  };
}
