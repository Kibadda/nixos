{ meta, ... }: {
  kibadda = {
    kitty.enable = false;
    yubikey.enable = false;
  };

  home = {
    sessionVariables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };

    file = let
      directory = ".config/helm";
    in {
      "${directory}/helmfile.yaml".text = ''
        repositories:
          - name: longhorn
            url: https://charts.longhorn.io
          - name: ingress-nginx
            url: https://kubernetes.github.io/ingress-nginx
          - name: cert-manager
            url: https://charts.jetstack.io
          - name: immich
            url: https://immich-app.github.io/immich-charts
        ---
        releases:
          - name: longhorn
            namespace: longhorn-system
            chart: longhorn/longhorn
            version: 1.7.1

          - name: ingress-nginx
            namespace: nginx-system
            chart: ingress-nginx/ingress-nginx
            version: 4.11.2

          - name: cert-manager
            namespace: cert-manager
            chart: cert-manager/cert-manager
            version: 1.15.3
            values:
              - ./values/cert-manager.yaml

          - name: immich
            namespace: immich-system
            chart: immich/immich
            version: 0.7.2
            values:
              - ./values/immich.yaml
      '';

      "${directory}/manifests.yaml".text = ''
        releases:
          - name: longhorn-storage
            chart: ./longhorn-storage

          - name: cert-issuer
            chart: ./cert-issuer

          - name: immich-pvc
            chart: ./immich-pvc
      '';

      "${directory}/longhorn-storage/manifest.yaml".text = ''
        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
          name: longhorn-storage
        provisioner: driver.longhorn.io
        allowVolumeExpansion: true
        parameters:
          numberOfReplicas: "1"
          staleReplicaTimeout: "2880"
          fromBackup: ""
          fsType: "ext4"
      '';

      "${directory}/immich-pvc/manifest.yaml".text = ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: immich-library
          namespace: immich-system
        spec:
          accessModes:
            - ReadWriteMany
          storageClassName: longhorn-storage
          resources:
            requests:
              storage: 500G
      '';

      "${directory}/cert-issuer/manifest.yaml".text = ''
        apiVersion: cert-manager.io/v1
        kind: ClusterIssuer
        metadata:
          name: letsencrypt-staging
        spec:
          acme:
            server: https://acme-staging-v02.api.letsencrypt.org/directory
            email: ${meta.email.personal}
            privateKeySecretRef:
              name: letsencrypt-staging
            solvers:
              - http01:
                  ingress:
                    ingressClassName: nginx
      '';

      "${directory}/values/cert-manager.yaml".text = ''
        crds:
          enabled: true
      '';

      "${directory}/values/immich.yaml".text = ''
        image:
          tag: v1.115.0
        immich:
          persistence:
            library:
              existingClaim: immich-library
          configuration:
            server:
              externalDomain: "https://fotos.xn--strobel-s-o1a23a.de"
            storageTemplate:
              enabled: true
              template: "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}"
        server:
          ingress:
            main:
              enabled: true
              ingressClassName: nginx
              annotations:
                nginx.ingress.kubernetes.io/proxy-body-size: "0"
                cert-manager.io/cluster-issuer: "letsencrypt-staging"
              hosts:
                - host: "fotos.xn--strobel-s-o1a23a.de"
                  paths:
                    - path: "/"
              tls:
                - hosts:
                    - "fotos.xn--strobel-s-o1a23a.de"
                  secretName: immich-tls
        postgresql:
          enabled: true
        redis:
          enabled: true
      '';
    };
  };
}
