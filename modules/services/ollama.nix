{
  pkgs,
  ...
}:
{
  services.ollama = {
    enable = false;
    loadModels = [ "llama3.2:1b" ];
    user = "ollama";
    package = pkgs.ollama-cpu;
    openFirewall = true;
    host = "0.0.0.0";
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "-1m";
    };
  };
}
