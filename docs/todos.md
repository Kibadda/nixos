# TODOs

## Paperless

```nix
{
  meta,
  ...
}:
{
  oberon.nginx."${meta.pi.paperless.domain}" = {
    restrict-access = true;
    port = 28981;
  };

  services.paperless = {
    enable = true;
    dataDir = meta.pi.paperless.dir;
    database.createLocally = true;
    environmentFile = "/etc/paperless/env";
    passwordFile = "/etc/paperless/pass";
    settings = {
      PAPERLESS_ADMIN_USER = meta.email;
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
    };
  };

  environment.etc = {
    "paperless/env".text = meta.pi.paperless.environment;
    "paperless/pass".text = meta.pi.paperless.password;
  };
}
```

## Vaultwarden

```nix
{
  meta,
  ...
}:
{
  oberon.nginx."${meta.pi.vaultwarden.domain}" = {
    restrict-access = true;
    port = 8000;
  };

  services.vaultwarden = {
    enable = true;
    environmentFile = "/etc/vaultwarden/env";
    config = {
      DOMAIN = "https://${meta.pi.vaultwarden.domain}";
      SINGUPS_ALLOWED = false;
      ROCKET_PORT = 8000;
    };
  };

  environment.etc = {
    "vaultwarden/env".text = meta.pi.vaultwarden.environment;
  };
}
```
