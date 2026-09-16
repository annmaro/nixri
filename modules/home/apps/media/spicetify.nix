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
    theme = {
      name = "Comfy";
      src = pkgs.fetchFromGitHub {
        owner = "Comfy-Themes";
        repo = "Spicetify";
        rev = "32ff101e27cfd33d85b7cc587f7f95db6b2df8b0";
        hash = "sha256-HxfBiDNGI41u1KK4Q6YdRrOylD2frNGDBx2jTanEaQs=";
      };
      injectCss = true;
      injectThemeJs = true;
      replaceColors = true;
      overwriteAssets = true;
      sidebarConfig = true;
      homeConfig = true;
    };
    colorScheme = "Sunset";
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle
      keyboardShortcut
      copyLyrics
    ];
  };
}
