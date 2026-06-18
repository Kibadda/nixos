{
  secrets,
  ...
}:
{
  flake.nixosModules.trilium =
    {
      config,
      pkgs,
      ...
    }:
    {
      kibadda.services.trilium = {
        description = "Notizen";
        subdomain = "notes";
        port = 8084;
        open = true;
        auth = "oidc";
        oidc = {
          redirect_uris = [
            "${config.kibadda.services.trilium.url}/callback"
          ];
          method = "basic";
          claim = {
            id_token = [
              "email"
              "name"
            ];
          };
        };
        backup.archive = [ "/mnt/trilium/document.db" ];
        section = "Apps";
      };

      services.trilium-server = {
        enable = true;
        port = 8084;
        noBackup = true;
        environmentFile = pkgs.writeText "trilium.env" ''
          TRILIUM_OAUTH_BASE_URL=${config.kibadda.services.trilium.url}
          TRILIUM_OAUTH_CLIENT_ID=trilium
          TRILIUM_OAUTH_CLIENT_SECRET=${secrets.pi.authelia.oidc.trilium}
          TRILIUM_OAUTH_ISSUER_BASE_URL=${config.kibadda.services.authelia.url}
          TRILIUM_OAUTH_ISSUER_NAME=Authelia
          TRILIUM_OAUTH_ISSUER_ICON=https://www.authelia.com/images/branding/logo-cropped.png
        '';
        dataDir = "/mnt/trilium";
      };
    };
}
