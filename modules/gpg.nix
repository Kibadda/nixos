{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.pinentry.defaultPackage.${pkgs.system}
  ];

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableSshSupport = true;
    defaultCacheTtl = 60;
    maxCacheTtl = 120;
    pinentryPackage = inputs.pinentry.defaultPackage.${pkgs.system};
  };
}
