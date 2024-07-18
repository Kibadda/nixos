{ inputs, outputs, config, lib, pkgs, meta, ... }: {
  imports = [
    ./modules/yubikey-gpg.nix
  ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.unstable
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = meta.hostname;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "JetBrainsMono";
    keyMap = "de";
  };

  fonts.packages = with pkgs; [
    (nerfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  users.users.michael = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCSugc5zJ7zTYJ5o503umJi3TOUBrL2gciJOTW7hqn/k55ehbnVsDIZLtE0oBbD2xJddwWCCeLADLfIStTBjEWeDh6Z59M7eD/qexU38pSr/PgkDQNaHvVDyjhVT0AdpqJPgnHbXGkXi/eH3mPGoFc9BwgXIOR6+VMnKykpZlu5QsmHy+lAm/dptEVteTQk6At7tfNT5o+IY7DQDQyeolkXTrgu6D8HqvGOxU5UUsN/WKloPS3yj8xPBvMVlZ9uZf5SzwCv9UpRw2Y5b90LndXbEvLNgIf7w9TVy8A1d17sP9/ZrFrGlVADKN7Bqu+xc56setXbArHY5icM/83irQnf5+qHKZ0QP5PsvYZ9i2ygXNa0zoZjRxA0cLq5ylCaYeRS5INlwQfIQyJbiivdVBiZdyd1MJD3YerNpwFOZUSOrrEfSSSVMK+SHHyyadMgG+UY84YC0a8KD2nGrfzmZw4N2OK4wIMWPHFn4su1a9KQ7WanDxK5meu2TtBe8a8l1EDvHh/by3E3/dWOdNt8tqAlr8SD0pctMuBCGqIgfaNAjX5/hVnxdhohQKgeHlM5R4t2H6kg6zXp+gLZt06xSQetS1m/UfM5tTCcdLe3hs+7f13x4vZ+3auqlY2xTwmmegbVdKShmD7Lzl1TYL3iIzqietwJ/5IxI1gc5HsUFx3T4Q== cardno:18_124_120"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    chromium
    git
    fzf
    jq
    ripgrep
    wl-clipboard
    stow
    unzip
    eza
    bat
    grim
    slurp
  ];

  virtualisation.docker.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  security.polkit.enable = true;

  programs.hyprland.enable = true;

  programs.zsh.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "23.11";
}
