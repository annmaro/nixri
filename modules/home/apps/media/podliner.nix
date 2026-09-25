{ pkgs, inputs, ... }:

let
  podlinerPkg = pkgs.callPackage ./podliner-pkg.nix {
    podlinerSrc = inputs.podliner;
  };
in
{
  home.packages = [ podlinerPkg ];
}
