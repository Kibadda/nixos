{
  secrets,
  self,
  ...
}:
{
  flake.nixosModules.mindwtr =
    {
      config,
      ...
    }:
    {
      imports = [
        self.nixosModules.virtualisation
      ];

      kibadda.services = {
        mindwtr-app = {
          description = "GTD";
          subdomain = "gtd";
          port = 5173;
          auth = "none";
          icon = "https://raw.githubusercontent.com/dongdongbh/Mindwtr/fa985a3a54bcf9e8707bab1241c3ca8e8b77c608/apps/mobile/assets/images/icon.png";
          section = "Apps";
        };

        mindwtr-cloud = {
          description = "GTD Cloud";
          subdomain = "gtd-cloud";
          port = 8787;
          auth = "none";
        };
      };

      virtualisation.oci-containers.containers = {
        mindwtr-app = {
          image = "ghcr.io/dongdongbh/mindwtr-app:latest";
          ports = [ "127.0.0.1:5173:5173" ];
        };

        mindwtr-cloud = {
          image = "ghcr.io/dongdongbh/mindwtr-cloud:latest";
          ports = [ "127.0.0.1:8787:8787" ];
          environment = {
            MINDWTR_CLOUD_AUTH_TOKENS = secrets.pi.mindwtr.token;
            MINDWTR_CLOUD_CORS_ORIGIN = config.kibadda.services.mindwtr-app.url;
          };
          volumes = [
            "/mnt/mindwtr/data:/app/cloud_data"
          ];
        };
      };

      systemd.tmpfiles.rules = [
        "d /mnt/mindwtr 0755 root root -"
        "d /mnt/mindwtr/data 0755 1000 1000 -"
      ];
    };
}
