{
  lib,
  secrets,
  ...
}:
{
  flake.nixosModules.psitransfer =
    {
      pkgs,
      ...
    }:
    {
      kibadda.services.psitransfer = {
        description = "Filesharing";
        subdomain = "share";
        port = 8432;
        auth = "none";
      };

      users = {
        groups.psitransfer = { };
        users.psitransfer = {
          group = "psitransfer";
          home = "/mnt/psitransfer";
          isSystemUser = true;
        };
      };

      systemd = {
        services.psitransfer = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = lib.getExe pkgs.psitransfer;
            Type = "simple";
            Restart = "on-failure";
            RestartSec = 3;
            EnvironmentFile = pkgs.writeText "psitransfer.env" ''
              PSITRANSFER_ADMIN_PASS=${secrets.pi.psitransfer.password}
              PSITRANSFER_UPLOAD_DIR=/mnt/psitransfer
              PSITRANSFER_PORT=8432
              PSITRANSFER_DEFAULT_LANGUAGE=de
              PSITRANSFER_MAIL_TEMPLATE="mailto:?subject=Datei&body=Hier kommt die Datei: %%URL%%"
            '';
            User = "psitransfer";
            Group = "psitransfer";
          };
        };

        tmpfiles.rules = [
          "d /mnt/psitransfer 0750 psitransfer psitransfer - -"
        ];
      };
    };
}
