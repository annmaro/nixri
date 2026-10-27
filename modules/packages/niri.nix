{
  inputs,
  config,
  lib,
  pkgs,
  bar,
}:

let
  baseNiri = pkgs.niri;

  wallpaper = pkgs.callPackage ./niri-scripts/wallpaper.nix { };
  screenRecorder = pkgs.callPackage ./niri-scripts/screen-record.nix { };

  settings = import ../data/niri/settings.nix {
    inherit config lib pkgs wallpaper screenRecorder bar;
  };
in
inputs.wrapper-modules.wrappers.niri.wrap {
  inherit pkgs settings;
  package = baseNiri;
}
