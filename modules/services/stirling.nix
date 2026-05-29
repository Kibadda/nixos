{
  flake.nixosModules.stirling = {
    kibadda.services.stirling = {
      description = "PDF";
      subdomain = "pdf";
      port = 8079;
      auth = "none";
      icon = "stirling-pdf.svg";
      section = "Tools";
    };

    services.stirling-pdf = {
      enable = true;
      environment = {
        SERVER_PORT = 8079;
        SYSTEM_ENABLEANALYTICS = "false";
      };
    };
  };
}
