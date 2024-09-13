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
      ".config/k3s/immich-pv.yaml".text = ''
        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
          name: longhorn-immich
        provisioner: driver.longhorn.io
        allowVolumeExpansion: true
        parameters:
          numberOfReplicas: "1"
          staleReplicaTimeout: "2880"
          fromBackup: ""
          fsType: "ext4"
        ---
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: immich-library
          namespace: immich-system
        spec:
          accessModes:
            - ReadWriteMany
          storageClassName: longhorn-immich
          resources:
            requests:
              storage: 4G
      '';

      ".config/k3s/helmfile.yaml".text = ''
        repositories:
          - name: longhorn
            url: https://charts.longhorn.io
          - name: immich
            url: https://immich-app.github.io/immich-charts
        ---
        releases:
          - name: longhorn
            namespace: longhorn-system
            chart: longhorn/longhorn
            version: 1.7.1

          - name: immich
            namespace: immich-system
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
              existingClaim: immich-library
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
