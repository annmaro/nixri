{
  inputs,
  config,
  lib,
  pkgs,
  bar,
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  baseNiri = inputs.niri.packages.${system}.niri-unstable;

  wallpaper = pkgs.callPackage ./niri-scripts/wallpaper.nix { };
  keybindsRofi = pkgs.callPackage ./niri-scripts/keybinds-rofi.nix { };
  screenRecorder = pkgs.callPackage ./niri-scripts/screen-record.nix { };

  settings = import ../data/niri/settings.nix {
    inherit config lib pkgs wallpaper keybindsRofi screenRecorder bar;
  };
in
inputs.wrapper-modules.wrappers.niri.wrap {
  inherit pkgs settings;
  package = baseNiri;
}
