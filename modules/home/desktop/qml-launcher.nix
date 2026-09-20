{ pkgs, ... }:

{
  home.packages = [ pkgs.quickshell ];

  xdg.configFile."qml-launcher/shell.qml".source = ../../../assets/qml-launcher/shell.qml;
}
