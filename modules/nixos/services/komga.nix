{ ... }:

{
  # 1. Automount the comics btrfs partition on demand
  fileSystems."/mnt/comics" = {
    device = "/dev/disk/by-uuid/fcd8693d-39c7-49cc-a9de-c18d15f2d69d";
    fsType = "btrfs";
    options = [
      "nofail"                      # Do not halt boot if drive is missing
      "x-systemd.automount"         # Mount automatically when directory is accessed
      "x-systemd.idle-timeout=10min" # Unmount after 10m idle
    ];
  };

  # 2. Ensure Komga persistent directories exist with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/komga 0755 1000 100 -"
    # Declarative Pi-hole local DNS record for komga.lan
    "f+ /var/lib/pihole/dnsmasq.d/05-custom-records.conf 0644 root root - address=/komga.lan/192.168.31.193\n"
  ];

  # 3. Komga container configuration
  virtualisation.oci-containers.containers.komga = {
    image = "gotson/komga:latest";
    user = "1000:100"; # annmaro:users
    ports = [
      "25600:25600" # Expose Komga's container port to host's network interfaces
    ];
    volumes = [
      "/var/lib/komga:/config"
      # Host path to Marvel Comics mapped to /data in container
      "/mnt/comics/Marvel_Comics:/data"
      "/mnt/comics:/mnt/comics"
    ];
    environment = {
      # Do not delete missing libraries if drive disconnects/fails to mount
      KOMGA_LIBRARIES_SCAN_DELETIONS = "false";
      TZ = "Asia/Kolkata";
    };
  };

  # 4. Dependency ordering: ensure docker-komga waits for the comics mount
  systemd.services."docker-komga" = {
    after = [ "mnt-comics.mount" ];
    requires = [ "mnt-comics.mount" ];
  };

  # 5. Open Komga port in NixOS firewall
  networking.firewall.allowedTCPPorts = [ 25600 ];
}
