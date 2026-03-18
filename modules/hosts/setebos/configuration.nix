{
  secrets,
  pkgs,
  ...
}:
{
  imports = [
    ../common/desktop.nix
    ../common/configuration.nix
    ../common/home.nix

    ../../modules/kibadda/configuration.nix
  ];

  environment = {
    systemPackages = [
      pkgs.cifs-utils
    ];

    etc."nixos/smbcredentials".text = secrets.work.smb.credentials;
  };

  fileSystems = {
    "/mnt/team" = {
      device = "//${secrets.work.smb.ip}/team";
      fsType = "cifs";
      options = [ "nofail,credentials=/etc/nixos/smbcredentials,uid=1000,gid=1000" ];
    };

    "/mnt/temp" = {
      device = "//${secrets.work.smb.ip}/temp";
      fsType = "cifs";
      options = [ "nofail,credentials=/etc/nixos/smbcredentials,uid=1000,gid=1000" ];
    };
  };
}
