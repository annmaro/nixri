{
  inputs,
  config,
  lib,
  pkgs,
}:

let
  baseNiri = pkgs.niri;

  wallpaper = pkgs.callPackage ./niri-scripts/wallpaper.nix { };
  screenRecorder = pkgs.callPackage ./niri-scripts/screen-record.nix { };

  settings = import ../data/niri/settings.nix {
    inherit config lib pkgs wallpaper screenRecorder;
  };
in
inputs.wrapper-modules.wrappers.niri.wrap {
  inherit pkgs settings;
  package = baseNiri;
}
