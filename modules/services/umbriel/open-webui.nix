{
  lib,
  secrets,
  ...
}:
{
  oberon = lib.mkIf false {
    nginx.${secrets.pi.open-webui.domain} = {
      restrict-access = true;
      host = "10.0.0.4";
      port = 11435;
      websockets = true;
    };

    authelia.open-webui = {
      secret = secrets.pi.authelia.oidc.open-webui;
      redirect_uris = [
        "https://${secrets.pi.open-webui.domain}/oauth/oidc/callback"
      ];
      scopes = [
        "openid"
        "email"
        "profile"
        "groups"
      ];
    };

    dashboard.Coding = [
      {
        name = "OpenAi";
        icon = "openai.svg";
        description = "Chat";
        url = "https://${secrets.pi.open-webui.domain}";
      }
    ];
  };
}
