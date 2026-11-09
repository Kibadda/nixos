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
          extra-substituters = [
            "https://cache.numtide.com"
            "https://kibadda.cachix.org"
          ];
          extra-trusted-public-keys = [
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
            "kibadda.cachix.org-1:5Hlak2ZLPMRbEbFvPbyuVhBeYdbTTayTrYuuaLLUl/g="
          ];
        };
      };

      nixpkgs = {
        overlays = [
          inputs.llm-agents.overlays.shared-nixpkgs
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
        openssh.authorizedKeys.keys = secrets.base.sshAuthorizedKeys;
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
