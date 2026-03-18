{
  inputs,
  secrets,
  ...
}:
{
  flake.homeModules.base =
    {
      pkgs,
      ...
    }:
    {
      home = {
        username = secrets.base.username;
        homeDirectory = "/home/${secrets.base.username}";
      };

      xdg.enable = true;
    };

  flake.nixosModules.base =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.nix-monitored.nixosModules.default
      ];

      nix = {
        package = lib.mkDefault pkgs.nixVersions.stable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        monitored = {
          enable = true;
          notify = false;
        };
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than +5";
        };
        settings = {
          auto-optimise-store = true;
          trusted-users = [
            secrets.base.username
          ];
        };
      };

      nixpkgs = {
        overlays = [
          inputs.nur.overlays.default
          inputs.work.overlays.default
        ];
        config = {
          allowUnsupportedSystem = true;
          allowUnfree = true;
        };
      };

      time.timeZone = "Europe/Berlin";

      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_TIME = "de_DE.UTF-8";
          LC_MONETARY = "de_DE.UTF-8";
        };
      };

      console = {
        font = "Lat2-Terminus16";
        keyMap = "de";
      };

      users.users.${secrets.base.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = "$6$t2GM2AFGTwx5HL1S$NuDSMSjd93Cm6Ud3uBMtaGVvFGdnJzgVlPOXYRWEras8eqeYhuSPuLA.lfBBFgWpTLEBOVlf2VlKoJqPvGZbC1";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/8n/+7PHOi/G90P2b8d4o8QOD5wgyLHkU4jsWL1gP1xVvrply0EHPFrDFMlnKorSCdJeJ5AsNvNmkZ7eS+VLDjKo+j8HdfF30Du9wemxlaI/Kl8h/SNXrE3p39i9FrwPmwhXy04lYa54dimXPQ4Q6mhVwwIrVn1L43KoZCxK0U8TLkiRo7CWMv9uRw91H5UC7yZJgoc4UYNKmoW/nUl5xIKUmpHWAL0LnSYaLSbTITsj/vYChmfJQcDOym8P3L5UiAN2mF3GTxxIu3fZ4AcCOHot5v830H9pILeAvuWGyX+n5zo3PTTJ2px38m64JHlNf6C2G9y5z/nvST2SWoB1nTopBie+rACZNkC/8sDb480YNkxUYEkkx3cZRzafado8GCWDDtNL7r0CeUkHA8CM9iHLm5AckaI3lB0/TtoKnc+6Q10GUanbjX8wuEMchI9YSHbTJd01yDgiDKGBXUAv2oMk8/C3KnFvuq74BeTGk45x0DYwuqHkBtH7Fud0OnvL511c74KNRyGzTq3IGe4Soi0IXBSTz7HL/ucS1zJ34iEcWieD76oz+qmWjnkoHP5NhTLJEiT6Hu9+2OLAl23uLhp0pRwAE43IKaJBZ56J7adZOVJTPCi8qBf7t37w5dp2WyvrSF0etNLhP6lKOg1U+9fnKsn0DR7RxY2rVwHSqbQ== cardno:18_124_120"
        ];
      };

      services.openssh = {
        enable = true;
        ports = [ secrets.home.sshPort ];
        settings = {
          StreamLocalBindUnlink = false;
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };

      networking.firewall.enable = true;

      security = {
        polkit.enable = true;
        sudo.execWheelOnly = true;
      };

      environment.systemPackages = with pkgs; [
        git
        fzf
        jq
        ripgrep
        unzip
        bat
        btop
        zstd
        dig
      ];
    };
}
