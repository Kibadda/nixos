{
  secrets,
  ...
}:
{
  oberon = {
    nginx."${secrets.pi.n8n.domain}" = {
      restrict-access = true;
      host = "10.0.0.4";
      port = 5678;
    };

    dashboard.n8n = {
      icon = "n8n.svg";
      description = "Automation";
      url = "https://${secrets.pi.n8n.domain}";
    };
  };
}
