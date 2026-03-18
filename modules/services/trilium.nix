{
  secrets,
  pkgs,
  ...
}:
{
  oberon = {
    nginx.${secrets.pi.trilium.domain} = {
      restrict-access = false;
      websockets = true;
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
      policy = "trilium";
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

  services.trilium-server = {
    enable = true;
    port = 8084;
    noBackup = true;
    environmentFile = pkgs.writeText "trilium.env" ''
      TRILIUM_OAUTH_BASE_URL=https://${secrets.pi.trilium.domain}
      TRILIUM_OAUTH_CLIENT_ID=trilium
      TRILIUM_OAUTH_CLIENT_SECRET=${secrets.pi.authelia.oidc.trilium}
      TRILIUM_OAUTH_ISSUER_BASE_URL=https://${secrets.pi.authelia.domain}
      TRILIUM_OAUTH_ISSUER_NAME=Authelia
      TRILIUM_OAUTH_ISSUER_ICON=https://www.authelia.com/images/branding/logo-cropped.png
    '';
    dataDir = secrets.pi.trilium.dir;
  };
}
