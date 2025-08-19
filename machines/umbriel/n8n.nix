{
  secrets,
  ...
}:
{
  services.n8n = {
    enable = true;
    webhookUrl = "https://${secrets.pi.n8n.domain}";
    settings = {
      # N8N_HIRING_BANNER_ENABLED = false;
      # N8N_HIDE_USAGE_PAGE = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    5678
  ];
}
