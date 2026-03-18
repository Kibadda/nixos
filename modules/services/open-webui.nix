{
  secrets,
  ...
}:
{
  services.open-webui = {
    enable = false;
    host = "0.0.0.0";
    port = 11435;
    openFirewall = true;
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_NAME = "LLM @ Home";

      WEBUI_URL = "https://${secrets.pi.open-webui.domain}";
      ENABLE_OAUTH_SIGNUP = "true";
      OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "true";
      OAUTH_CLIENT_ID = "open-webui";
      OAUTH_CLIENT_SECRET = secrets.pi.authelia.oidc.open-webui;
      OPENID_PROVIDER_URL = "https://${secrets.pi.authelia.domain}/.well-known/openid-configuration";
      OAUTH_PROVIDER_NAME = "Authelia";
      ENABLE_OAUTH_ROLE_MANAGEMENT = "true";
      OAUTH_SCOPES = "openid email profile groups";
      OAUTH_ADMIN_ROLES = "admin";
      OAUTH_ROLES_CLAIM = "groups";
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      onnxruntime = prev.onnxruntime.overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags ++ [
          (prev.lib.cmakeBool "onnxruntime_ENABLE_CPUINFO" false)
        ];
      });
    })
  ];
}
