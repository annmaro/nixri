{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.systemSettings.videoDriver == "intel") {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        intel-compute-runtime
      ];
    };

    services.xserver.videoDrivers = [ "modesetting" ];
  };
}
