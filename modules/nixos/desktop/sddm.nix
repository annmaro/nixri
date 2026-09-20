{ config, inputs, lib, pkgs, ... }:

let
  wallpaper = ../../../assets/output.mp4;
  silviaWallpaper = pkgs.runCommand "silvia.mp4" { } ''
    cp ${wallpaper} $out
  '';
  profileIcon = ../../../assets/nix.png;
in
{
  imports = [ inputs.silentSDDM.nixosModules.default ];


  programs.silentSDDM = {
    enable = true;
    theme = "silvia";
    backgrounds = {
      output = wallpaper;
      silvia = silviaWallpaper;
    };
    profileIcons.${config.systemSettings.username} = profileIcon;
    settings = {
      "General" = {
        "animated-background-placeholder" = "";
        "background-fill-mode" = "fill";
      };
      "LoginScreen" = {
        background = "output.mp4";
        use-background-color = false;
      };
      "LockScreen" = {
        display = false;
        background = "output.mp4";
        use-background-color = false;
      };
    };
  };

  services.displayManager = {
    sddm.wayland.enable = lib.mkForce true;
    defaultSession = "niri";
  };
}
