{ inputs, pkgs, ... }:

{
  imports = [ inputs.nixvirt.nixosModules.default ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    docker = {
      enable = true;
      enableOnBoot = true;
    };
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    lazydocker
  ];
}
