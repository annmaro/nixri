{ config, ... }:

{
  services.syncthing = {
    enable = true;
    settings = {
      folders = {
        "Notes" = {
          path = "${config.home.homeDirectory}/Notes";
        };
        "Music" = {
          path = "${config.home.homeDirectory}/Music";
        };
      };
    };
  };
}
