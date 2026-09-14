{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  # Ensure nixvirt is passed via inputs in your flake.nix
  nixvirt = inputs.nixvirt;
in
{
  # Import the NixVirt NixOS module
  imports = [
    nixvirt.nixosModules.default
  ];

  # Enable standard libvirtd options
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  docker = {
    enable = true;
  };

  # Helpful packages for managing VMs
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    lazydocker
    docker-client
  ];

  /*
    # NixVirt configuration for qemu:///system
    virtualisation.libvirt.connections."qemu:///system" = {

      # Declarative Virtual Machine (Domain) definition
      domains = [
        {
          # Using raw XML gives you absolute control over performance tweaks
          # (like host-passthrough, cache writeback, io threads, 3d acceleration)
          definition = pkgs.writeText "nixos-vm.xml" ''
            <domain type='kvm'>
              <name>nixos-perf-vm</name>
              <memory unit='KiB'>8388608</memory>
              <cpu mode='host-passthrough' check='none'>
                <topology sockets='1' dies='1' clusters='1' cores='4' threads='2'/>
              </cpu>

              <os>
                <type arch='x86_64' machine='q35'>hvm</type>
                <loader readonly='yes' type='pflash'>/run/libvirt/nix-ovmf/OVMF_CODE.fd</loader>
              </os>

              <devices>
                <emulator>/run/current-system/sw/bin/qemu-kvm</emulator>

                <disk type='file' device='disk'>
                  <driver name='qemu' type='qcow2' cache='writeback' io='threads'/>
                  <!-- Point this to where your NixOS qcow2 image will live -->
                  <source file='/var/lib/libvirt/images/nixos.qcow2'/>
                  <target dev='vda' bus='virtio'/>
                </disk>

                <interface type='network'>
                  <source network='default'/>
                  <model type='virtio'/>
                </interface>

                <video>
                  <model type='virtio' vram='65536' heads='1' primary='yes'>
                    <acceleration accel3d='yes'/>
                  </model>
                </video>

                <channel type='spicevmc'>
                  <target type='virtio' name='com.redhat.spice.0'/>
                </channel>
              </devices>
            </domain>
          '';

          # Keep the state of the machine synced seamlessly with nixos-rebuild switch
          active = true;
        }
      ];
    };

    # Automatically provision the storage disk if it doesn't exist
    system.activationScripts.provision-vm-storage = {
      text = ''
        mkdir -p /var/lib/libvirt/images
        if [ ! -f /var/lib/libvirt/images/nixos.qcow2 ]; then
          # Creates a high-performance 40GB thin-provisioned virtual disk instantly
          ${pkgs.qemu}/bin/qemu-img create -f qcow2 /var/lib/libvirt/images/nixos.qcow2 40G
        fi
      '';
    };
  */
}
