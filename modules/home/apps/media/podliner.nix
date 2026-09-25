{ pkgs, inputs, ... }:

let
  podlinerPkg = pkgs.callPackage ../../../packages/podliner {
    podlinerSrc = inputs.podliner;
  };
in
{
  home.packages = [ podlinerPkg ];
}
