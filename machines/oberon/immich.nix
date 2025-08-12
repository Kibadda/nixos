{
  meta,
  ...
}:
{
  oberon = {
    nginx."${meta.pi.immich.domain}" = {
      restrict-access = true;
      port = 2283;
      websockets = true;
      extraConfig = ''
        client_max_body_size 50000M;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        send_timeout 600s;
      '';
    };

    backup.immich = {
      path = meta.pi.immich.dir;
      time = "03:15";
    };
  };

  services.immich = {
    enable = true;
    openFirewall = true;
    machine-learning.enable = true;
    settings = {
      server.externalDomain = "https://${meta.pi.immich.domain}";
      storageTemplate = {
        enabled = true;
        template = "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}";
      };
    };
    mediaLocation = meta.pi.immich.dir;
  };

  systemd.tmpfiles.rules = [
    "d ${meta.pi.immich.dir} 0750 immich immich - -"
    "x ${meta.pi.immich.dir}"
  ];
}
