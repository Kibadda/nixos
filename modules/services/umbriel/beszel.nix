{
  secrets,
  ...
}:
{
  services.beszel.agent = {
    enable = true;
    environment = {
      KEY = secrets.pi.beszel.umbriel.key;
      TOKEN = secrets.pi.beszel.umbriel.token;
      HUB_URL = "https://${secrets.pi.beszel.domain}";
    };
    openFirewall = true;
  };
}
