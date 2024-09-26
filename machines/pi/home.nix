{ meta, ... }: {
  kibadda = {
    kitty.enable = false;
    yubikey.enable = false;
  };

  home = {
    sessionVariables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };

    file = {
      ".config/helm" = {
        source = ./k3s;
        recursive = true;
      };

      ".config/helm/cert-issuer.yaml".text = ''
        apiVersion: cert-manager.io/v1
        kind: ClusterIssuer
        metadata:
          name: letsencrypt-production
        spec:
          acme:
            server: https://acme-v02.api.letsencrypt.org/directory
            email: ${meta.email.personal}
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
