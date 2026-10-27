{ inputs, pkgs, ... }:

{
  home.packages = [
    (inputs.bookokrat.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (_old: {
      doCheck = false;
    }))
  ];
}
