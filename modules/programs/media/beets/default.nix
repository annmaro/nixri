{
  config,
  lib,
  pkgs,
  ...
}:

{
  home-manager.sharedModules = [
    (_: {

      programs.beets = {
        enable = true;
        settings = {
          directory = "~/Music";
          library = "~/Data/musiclibrary.db";
          import = {
            copy = "no";
          };
          plugins = [
            "musicbrainz"
            "chroma"
            "discogs"
          ];
        };
      };
    })
  ];
}
