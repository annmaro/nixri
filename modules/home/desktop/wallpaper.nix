{ pkgs, ... }:

let
  wallpaper = pkgs.callPackage ../../packages/niri-scripts/wallpaper.nix { };
in
{
  home.packages = with pkgs; [
    awww
    mpvpaper
    waypaper
    wallpaper
  ];

  xdg.configFile."waypaper/config.ini".text = ''
    [Settings]
    language = en
    folder = ~/Pictures/Wallpapers
    monitors = All
    wallpaper = ~/Pictures/Wallpapers/output.mp4
    backend = awww
    fill = fill
    sort = name
    post_command = ${wallpaper}/bin/wallpaper
  '';
}
