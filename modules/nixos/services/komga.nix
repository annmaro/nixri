{ ... }:

{
  # 1. Mount the Data partition containing Marvel_Comics and user media
  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-uuid/fcd8693d-39c7-49cc-a9de-c18d15f2d69d";
    fsType = "btrfs";
    options = [
      "nofail"                      # Do not halt boot if drive is missing
      "x-systemd.automount"         # Mount automatically when accessed
      "x-gvfs-show"                 # Force Thunar / GVFS to show this drive in the sidebar
      "x-gvfs-name=Data"            # Display name in Thunar sidebar
    ];
  };

  # 2. Compatibility symlinks & persistent directories
  systemd.tmpfiles.rules = [
    "d /var/lib/komga 0755 1000 100 -"
    # Symlinks so both /mnt/comics and legacy /run/media/annmaro/Data paths work seamlessly
    "L+ /mnt/comics - - - - /mnt/Data"
    "d /run/media/annmaro 0755 annmaro users -"
    "L+ /run/media/annmaro/Data - - - - /mnt/Data"
    # Declarative Pi-hole local DNS record for komga.lan pointing to host IP
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
      # Marvel Comics mapped to /data in container
      "/mnt/Data/Marvel_Comics:/data"
      "/mnt/Data:/mnt/Data"
    ];
    environment = {
      # Do not delete missing libraries if drive disconnects/fails to mount
      KOMGA_LIBRARIES_SCAN_DELETIONS = "false";
      TZ = "Asia/Kolkata";
    };
  };

  # 4. Dependency ordering: ensure docker-komga starts the mount before running
  systemd.services."docker-komga" = {
    after = [ "mnt-Data.mount" ];
    wants = [ "mnt-Data.mount" ];
  };

  # 5. Open Komga port in NixOS firewall
  networking.firewall.allowedTCPPorts = [ 25600 ];
}
