{
  self,
  ...
}:
{
  flake.nixosModules.bindarr =
    {
      config,
      ...
    }:
    {
      imports = [
        self.nixosModules.virtualisation
      ];

      kibadda.services.bindarr = {
        description = "MTG Collection";
        subdomain = "mtg";
        port = 6421;
        auth = "none";
        icon = "https://raw.githubusercontent.com/thenotoriousJeremy/bindarr/blob/a2edd30f652dcf8d50ef3a584e79f7ec6484063a/frontend/public/logo.svg";
        section = "Apps";
      };

      virtualisation.oci-containers.containers.bindarr = {
        image = "ghcr.io/thenotoriousjeremy/bindarr:1.8.4";
        ports = [ "127.0.0.1:6421:3001" ];
        environment = {
          TRUST_PROXY = 1;
          PUBLIC_BASE_URL = config.kibadda.service.bindarr.url;
          ALLOW_REGISTRATION = false;
        };
        volumes = [
          "/mnt/bindarr/data:/app/database"
        ];
      };

      systemd.tmpfiles.rules = [
        "d /mnt/bindarr 0755 root root -"
        "d /mnt/bindarr/data 0755 root root -"
      ];
    };
}
