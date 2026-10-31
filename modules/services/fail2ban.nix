{
  secrets,
  ...
}:
{
  flake.nixosModules.fail2ban = {
    networking.firewall.extraCommands = ''
      iptables -I nixos-fw -p tcp -s 10.0.0.0/24 --dport ${toString secrets.home.sshPort} -j nixos-fw-accept
    '';

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
      jails = {
        sshd.settings = {
          maxretry = 10;
          bantime = "1h";
        };
      };
    };
  };
}
