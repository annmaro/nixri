{ inputs, pkgs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];


  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.sleek;
    colorScheme = "dark";
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle
      keyboardShortcut
      copyLyrics
    ];
  };
}
