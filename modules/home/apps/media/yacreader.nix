{ pkgs, ... }:

{
  home.packages = with pkgs; [
    yacreader
  ];
}
