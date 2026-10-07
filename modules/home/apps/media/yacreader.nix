{ pkgs, ... }:

{
  home.packages = with pkgs; [
    yacreaderApp
  ];
}
