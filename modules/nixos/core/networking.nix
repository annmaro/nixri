{ config, pkgs, ... }:

{
  networking = {
    hostName = config.systemSettings.hostname;
    networkmanager.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        59010
        59011
        8080
      ];
      allowedUDPPorts = [
        59010
        59011
      ];
    };
  };

  environment.systemPackages = [ pkgs.networkmanagerapplet ];
}
