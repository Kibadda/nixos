{
  inputs,
  secrets,
  ...
}:
{
  flake.nixosModules.mtg-collection =
    {
      pkgs,
      ...
    }:
    let
      path = "/mnt/mtg-collection/collection.json";
    in
    {
      imports = [
        inputs.mtg-collection.nixosModules.default
      ];

      kibadda.services.mtg = {
        description = "MTG Collection";
        port = 8421;
        auth = "none";
        backup.archive = [
          path
        ];
        section = "Apps";
      };

      services.mtg-server = {
        enable = true;
        bind = "127.0.0.1";
        port = 8421;
        collectionPath = path;
      };
    };

  flake.homeModules.mtg-collection =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.mtg-collection.homeManagerModules.default
      ];

      programs.mtg-collection = {
        enable = true;
        serverUrl = "https://mtg.${secrets.pi.domain}";
      };
    };
}
