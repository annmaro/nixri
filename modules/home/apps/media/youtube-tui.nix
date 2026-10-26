{ pkgs, self, ... }:

let
  rustypipe-botguard = pkgs.callPackage "${self}/modules/packages/rustypipe-botguard.nix" { };
in
{
  home.packages = with pkgs; [
    youtube-tui
    rustypipe-botguard
  ];
}
