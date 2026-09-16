{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  wrappedNiri = pkgs.callPackage ../../packages/niri.nix {
    inherit inputs config;
    bar = "DMS";
  };
in
{
  imports = [
    ./dms
    ./rofi
    ./stylix
    ./swaylock
  ];

  config = lib.mkIf (config.systemSettings.bar == "DMS") {
    environment.systemPackages = with pkgs; [
      cliphist
      satty
      libnotify
      wtype
      wl-clipboard
      pavucontrol
      brightnessctl
      playerctl
      pamixer
      grim
      slurp
      thunar-volman
      gnome-disk-utility
      wlsunset
    ];

    nix.settings = {
      substituters = [ "https://niri.cachix.org" ];
      trusted-public-keys = [
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      ];
    };

    services.displayManager.defaultSession = "niri";

    programs.niri = {
      enable = true;
      package = wrappedNiri;
    };


    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
      xdgOpenUsePortal = true;
      configPackages = [ config.programs.niri.package ];
      config.niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.OpenURI" = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.Print" = "gtk";
      };
    };
  };
}
