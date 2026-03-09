{
  secrets,
  pkgs,
  ...
}:
{
  oberon = {
    nginx.${secrets.pi.trilium.domain} = {
      restrict-access = true;
      port = 8084;
    };

    backup.trilium = {
      path = secrets.pi.trilium.dir;
      time = "03:30";
    };

    authelia.trilium = {
      secret = secrets.pi.authelia.oidc.trilium;
      redirect_uris = [
        "https://${secrets.pi.trilium.domain}/callback"
      ];
    };

    dashboard.Home = [
      {
        name = "Trilium";
        icon = "trilium.svg";
        description = "Notes";
        url = "https://${secrets.pi.trilium.domain}";
      }
    ];
  };

  services.trilium = {
    enable = true;
    port = 8084;
    noBackup = true;
    environmentFile = pkgs.writeText "trilium.env" ''
      TRILIUM_MULTIFACTORAUTHENTICATION_OAUTHBASEURL=https://${secrets.pi.trilium.domain}
      TRILIUM_MULTIFACTORAUTHENTICATION_OAUTHCLIENTID=trilium
      TRILIUM_MULTIFACTORAUTHENTICATION_OAUTHCLIENTSECRET=${secrets.pi.authelia.oidc.trilium}
      TRILIUM_MULTIFACTORAUTHENTICATION_OAUTHISSUERBASEURL=https://${secrets.pi.authelia.domain}
      TRILIUM_MULTIFACTORAUTHENTICATION_OAUTHISSUERNAME=Authelia
    '';
    dataDir = secrets.pi.trilium.dir;
  };
}
