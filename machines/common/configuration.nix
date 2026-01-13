{
  inputs,
  pkgs,
  hostname,
  secrets,
  lib,
  config,
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
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
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
        inputs.work.overlays.default

        (final: prev: {
          unstable = import inputs.unstable-nixpkgs {
            system = final.stdenv.hostPlatform.system;
          };
        })

        packages.overlays.default
      ];
    config.allowUnsupportedSystem = true;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "intelephense"
        "spotify"
        "steam"
        "steam-original"
        "steam-run"
        "steam-unwrapped"
        "nvidia-x11"
        "nvidia-settings"
        "discord"
        "oneplus-sdm845-firmware-zstd"
        "oneplus-sdm845-firmware"
        "claude-code"
        "SpaceCadetPinball"
        "unrar"
        "n8n"
        "open-webui"
      ];
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

  fonts.fontDir.enable = true;

  hardware.bluetooth.enable = true;

  users.users.${secrets.base.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$t2GM2AFGTwx5HL1S$NuDSMSjd93Cm6Ud3uBMtaGVvFGdnJzgVlPOXYRWEras8eqeYhuSPuLA.lfBBFgWpTLEBOVlf2VlKoJqPvGZbC1";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/8n/+7PHOi/G90P2b8d4o8QOD5wgyLHkU4jsWL1gP1xVvrply0EHPFrDFMlnKorSCdJeJ5AsNvNmkZ7eS+VLDjKo+j8HdfF30Du9wemxlaI/Kl8h/SNXrE3p39i9FrwPmwhXy04lYa54dimXPQ4Q6mhVwwIrVn1L43KoZCxK0U8TLkiRo7CWMv9uRw91H5UC7yZJgoc4UYNKmoW/nUl5xIKUmpHWAL0LnSYaLSbTITsj/vYChmfJQcDOym8P3L5UiAN2mF3GTxxIu3fZ4AcCOHot5v830H9pILeAvuWGyX+n5zo3PTTJ2px38m64JHlNf6C2G9y5z/nvST2SWoB1nTopBie+rACZNkC/8sDb480YNkxUYEkkx3cZRzafado8GCWDDtNL7r0CeUkHA8CM9iHLm5AckaI3lB0/TtoKnc+6Q10GUanbjX8wuEMchI9YSHbTJd01yDgiDKGBXUAv2oMk8/C3KnFvuq74BeTGk45x0DYwuqHkBtH7Fud0OnvL511c74KNRyGzTq3IGe4Soi0IXBSTz7HL/ucS1zJ34iEcWieD76oz+qmWjnkoHP5NhTLJEiT6Hu9+2OLAl23uLhp0pRwAE43IKaJBZ56J7adZOVJTPCi8qBf7t37w5dp2WyvrSF0etNLhP6lKOg1U+9fnKsn0DR7RxY2rVwHSqbQ== cardno:18_124_120"
    ];
  };

  services = {
    openssh = {
      enable = true;
      ports = [ secrets.home.sshPort ];
      settings = {
        StreamLocalBindUnlink = false;
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
    };
  };

  networking = {
    hostName = hostname;
    firewall.enable = true;
  };

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
    pinentry-curses
    btop
    zstd
    dig
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05";
}
