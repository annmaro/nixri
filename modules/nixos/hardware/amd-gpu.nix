{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.systemSettings.videoDriver == "amdgpu") {
    boot.initrd.kernelModules = [ "amdgpu" ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva-vdpau-driver
        mesa
      ];
    };

    services.xserver.videoDrivers = [ "amdgpu" ];
  };
}
