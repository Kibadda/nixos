{ outputs, pkgs, meta, lib, config, ... }: {
  imports = [
    ./modules/kibadda/configuration.nix
    ./machines/${meta.hostname}/hardware-configuration.nix
    ./machines/${meta.hostname}/disko-config.nix
    ./machines/${meta.hostname}/configuration.nix
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings.auto-optimise-store = true;
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.unstable
    ];
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "google-chrome"
      "intelephense"
      "spotify"
      "steam"
      "steam-original"
      "steam-run"
    ];
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = meta.hostname;
    networkmanager.enable = true;
    firewall.enable = false;
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
    font = "${config.home-manager.users.${meta.username}.kibadda.font} Nerd Font";
    keyMap = "de";
  };

  fonts.fontDir.enable = true;

  hardware = {
    pulseaudio.enable = true;
    bluetooth.enable = true;
  };

  users.users.${meta.username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ];
    hashedPassword = "$6$t2GM2AFGTwx5HL1S$NuDSMSjd93Cm6Ud3uBMtaGVvFGdnJzgVlPOXYRWEras8eqeYhuSPuLA.lfBBFgWpTLEBOVlf2VlKoJqPvGZbC1";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCSugc5zJ7zTYJ5o503umJi3TOUBrL2gciJOTW7hqn/k55ehbnVsDIZLtE0oBbD2xJddwWCCeLADLfIStTBjEWeDh6Z59M7eD/qexU38pSr/PgkDQNaHvVDyjhVT0AdpqJPgnHbXGkXi/eH3mPGoFc9BwgXIOR6+VMnKykpZlu5QsmHy+lAm/dptEVteTQk6At7tfNT5o+IY7DQDQyeolkXTrgu6D8HqvGOxU5UUsN/WKloPS3yj8xPBvMVlZ9uZf5SzwCv9UpRw2Y5b90LndXbEvLNgIf7w9TVy8A1d17sP9/ZrFrGlVADKN7Bqu+xc56setXbArHY5icM/83irQnf5+qHKZ0QP5PsvYZ9i2ygXNa0zoZjRxA0cLq5ylCaYeRS5INlwQfIQyJbiivdVBiZdyd1MJD3YerNpwFOZUSOrrEfSSSVMK+SHHyyadMgG+UY84YC0a8KD2nGrfzmZw4N2OK4wIMWPHFn4su1a9KQ7WanDxK5meu2TtBe8a8l1EDvHh/by3E3/dWOdNt8tqAlr8SD0pctMuBCGqIgfaNAjX5/hVnxdhohQKgeHlM5R4t2H6kg6zXp+gLZt06xSQetS1m/UfM5tTCcdLe3hs+7f13x4vZ+3auqlY2xTwmmegbVdKShmD7Lzl1TYL3iIzqietwJ/5IxI1gc5HsUFx3T4Q== cardno:18_124_120"
    ];
  };

  security = {
    polkit.enable = true;
    sudo.execWheelOnly = true;
  };

  environment = {
    systemPackages = with pkgs; [
      git
      fzf
      jq
      ripgrep
      stow
      unzip
      bat
      playerctl
      brightnessctl
      vim
      pamixer
      pinentry-curses
      xdg-utils
      tree
      spotify
      telegram-desktop
    ];
  };

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
