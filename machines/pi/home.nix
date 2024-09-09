{
  kibadda = {
    kitty.enable = false;
    yubikey.enable = false;
  };

  home = {
    sessionVariables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };

    file = {
      ".config/k3s/helmfile.yaml".text = ''
        repositories:
          - name: immich
            url: https://immich-app.github.io/immich-charts
        ---
        releases:
          - name: immich
            namespace: immich
            chart: immich/immich
            version: 0.7.2
            values:
              - ./values/immich.values.yaml
      '';

      ".config/k3s/values/immich.values.yaml".text = ''
        image:
          tag: v1.106.1
        immich:
          persistence:
            library:
        postgresql:
          enabled: true
        resis:
          enabled: true
        machine-learning:
          enabled: false
      '';
    };
  };
}
