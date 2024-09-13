{
  kibadda = {
    kitty.enable = false;
    yubikey.enable = false;
  };

  home = {
    sessionVariables = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };

    file.".config/k3s" = {
      source = ./k3s;
      recursive = true;
    };
  };
}
