{ pkgs, ... }:

let
  rustypipe-botguard = pkgs.callPackage ./rustypipe-botguard.nix { };
in
{
  home.packages = with pkgs; [
    youtube-tui
    rustypipe-botguard
  ];
}
