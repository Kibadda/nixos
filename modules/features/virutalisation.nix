{
  secrets,
  ...
}:
{
  flake.nixosModules.virtualisation = {
    virtualisation = {
      podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
        # defaultNetwork.settings.dns_enabled = true;
      };

      oci-containers = {
        backend = "podman";
      };
    };

    users.users.${secrets.base.username}.extraGroups = [ "podman" ];
  };
}
