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
          - name: ingress-nginx
            url: https://kubernetes.github.io/ingress-nginx
          - name: cert-manager
            url: https://charts.jetstack.io
          - name: immich
            url: https://immich-app.github.io/immich-charts
        ---
        releases:
          - name: ingress-nginx
            namespace: nginx-system
            chart: ingress-nginx/ingress-nginx
            version: 4.11.2

          - name: cert-manager
            namespace: cert-manager
            chart: cert-manager/cert-manager
            version: 1.15.3
            values:
              - ./cert-manager.values.yaml

          - name: immich
            namespace: immich-system
            chart: immich/immich
            version: 0.7.2
            values:
              - ./immich.values.yaml
      '';

      "${directory}/cert-manager.values.yaml".text = ''
        crds:
          enabled: true
      '';

      "${directory}/immich.values.yaml".text = ''
        image:
          tag: v1.116.2
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
                cert-manager.io/cluster-issuer: "letsencrypt-production"
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

      "${directory}/immich-pvc.yaml".text = ''
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: immich-library
          namespace: immich-system
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 500G
      '';

      "${directory}/cert-issuer.production.yaml".text = ''
        apiVersion: cert-manager.io/v1
        kind: ClusterIssuer
        metadata:
          name: letsencrypt-production
        spec:
          acme:
            server: https://acme-v02.api.letsencrypt.org/directory
            email: ${meta.email}
            privateKeySecretRef:
              name: letsencrypt-production
            solvers:
              - http01:
                  ingress:
                    ingressClassName: nginx
      '';

      "${directory}/cert-issuer.staging.yaml".text = ''
        apiVersion: cert-manager.io/v1
        kind: ClusterIssuer
        metadata:
          name: letsencrypt-staging
        spec:
          acme:
            server: https://acme-staging-v02.api.letsencrypt.org/directory
            email: ${meta.email}
            privateKeySecretRef:
              name: letsencrypt-staging
            solvers:
              - http01:
                  ingress:
                    ingressClassName: nginx
      '';
    };
  };
}
