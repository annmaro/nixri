{ pkgs, ... }:

{
  boot = {
    supportedFilesystems = [
      "ntfs"
      "exfat"
      "ext4"
      "fat32"
      "btrfs"
    ];

    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_zen;
    kernel.sysctl."vm.swappiness" = 100;
    kernelParams = [
      "preempt=full"
      "i915.enable_dc=0"
      "i915.enable_psr=0"
    ];

    loader = {
      systemd-boot.enable = true;
      systemd-boot.consoleMode = "auto";
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      timeout = 10;
      grub.enable = false;
    };

    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };
}
