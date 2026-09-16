{ config, lib, pkgs, ... }:

let
  username = config.systemSettings.username;
  flakePath = "/home/${username}/nixri";
in
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 2d --keep 2";
    };
    flake = lib.mkDefault flakePath;
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd
  ];
}
