{
  secrets,
  self,
  ...
}:
{
  flake.homeModules.homeoffice =
    {
      selfpkgs,
      ...
    }:
    {
      imports = [
        self.homeModules.office
      ];

      home = {
        packages = [
          selfpkgs.work-helper
        ];

        file.".smbcredentials".text = secrets.work.smb.credentials;
      };

      kibadda = {
        git.includes = [
          {
            condition = "gitdir:/mnt/studiesbeta/";
            contents = {
              user.email = secrets.work.email;
              pull.rebase = false;
            };
          }
          {
            condition = "gitdir:/mnt/beta/";
            contents = {
              user.email = secrets.work.email;
              pull.rebase = false;
            };
          }
        ];
      };
    };

  flake.nixosModules.homeoffice = {
    imports = [
      self.nixosModules.office
    ];

    kibadda = {
      vpn.work = true;

      gnome.keybindings = [
        {
          name = "firefox work";
          command = "firefox -P work";
          binding = "<Control><Super>B";
        }
      ];
    };
  };
}
