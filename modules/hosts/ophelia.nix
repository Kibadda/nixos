{
  inputs,
  self,
  ...
}:
{
  nixosConfigurations.ophelia = {
    system = "aarch64-linux";

    configuration = {
      kibadda.vpn.home = true;
    };

    home = { };

    nixosModules = [
      (import "${inputs.mobile-nixos}/lib/configuration.nix" { device = "oneplus-enchilada"; })

      self.nixosModules.base

      self.nixosModules.zsh

      self.nixosModules.gnome
      self.nixosModules.vpn
    ];

    homeModules = [
      self.homeModules.base

      self.homeModules.zsh

      self.homeModules.direnv
      self.homeModules.eza
      self.homeModules.firefox
      self.homeModules.git
      self.homeModules.kitty
      self.homeModules.neovim
      self.homeModules.ssh
      self.homeModules.zoxide
    ];
  };
}
