{
  ...
}:
{
  services.ollama = {
    enable = true;
    loadModels = [ "llama3.2:1b" ];
    user = "ollama";
    acceleration = false;
    openFirewall = true;
    host = "0.0.0.0";
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "-1m";
    };
  };
}
