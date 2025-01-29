{
  meta,
  pkgs,
  inputs,
  ...
}:
{
  system.stateVersion = "24.05";

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [
        meta.username
      ];
    };
  };

  nixpkgs = {
    overlays =
      let
        packages = import ../../packages;
      in
      [
        inputs.nur.overlays.default

        inputs.dmenu.overlays.default
        inputs.powermenu.overlays.default
        inputs.passmenu.overlays.default
        inputs.pinentry.overlays.default
        inputs.nvim.overlays.default

        packages.overlays.default
      ];
    # TODO: add unfree predicate
    config.allowUnfree = true;
  };

  i18n.extraLocaleSettings = {
    LC_TIME = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
  };

  security.sudo.execWheelOnly = true;

  console.keyMap = "de";

  networking = {
    hostName = meta.hostname;
    firewall.enable = true;
  };

  services = {
    openssh = {
      enable = true;
      ports = [ meta.sshPort ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  programs.zsh.enable = true;

  users.users.${meta.username} = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$t2GM2AFGTwx5HL1S$NuDSMSjd93Cm6Ud3uBMtaGVvFGdnJzgVlPOXYRWEras8eqeYhuSPuLA.lfBBFgWpTLEBOVlf2VlKoJqPvGZbC1";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/8n/+7PHOi/G90P2b8d4o8QOD5wgyLHkU4jsWL1gP1xVvrply0EHPFrDFMlnKorSCdJeJ5AsNvNmkZ7eS+VLDjKo+j8HdfF30Du9wemxlaI/Kl8h/SNXrE3p39i9FrwPmwhXy04lYa54dimXPQ4Q6mhVwwIrVn1L43KoZCxK0U8TLkiRo7CWMv9uRw91H5UC7yZJgoc4UYNKmoW/nUl5xIKUmpHWAL0LnSYaLSbTITsj/vYChmfJQcDOym8P3L5UiAN2mF3GTxxIu3fZ4AcCOHot5v830H9pILeAvuWGyX+n5zo3PTTJ2px38m64JHlNf6C2G9y5z/nvST2SWoB1nTopBie+rACZNkC/8sDb480YNkxUYEkkx3cZRzafado8GCWDDtNL7r0CeUkHA8CM9iHLm5AckaI3lB0/TtoKnc+6Q10GUanbjX8wuEMchI9YSHbTJd01yDgiDKGBXUAv2oMk8/C3KnFvuq74BeTGk45x0DYwuqHkBtH7Fud0OnvL511c74KNRyGzTq3IGe4Soi0IXBSTz7HL/ucS1zJ34iEcWieD76oz+qmWjnkoHP5NhTLJEiT6Hu9+2OLAl23uLhp0pRwAE43IKaJBZ56J7adZOVJTPCi8qBf7t37w5dp2WyvrSF0etNLhP6lKOg1U+9fnKsn0DR7RxY2rVwHSqbQ== cardno:18_124_120"
    ];
  };

  fonts.fontDir.enable = true;

  time.timeZone = "Europe/Berlin";
}
