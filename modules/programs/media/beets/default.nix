{ config, lib, pkgs, ... }:

{
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
}
