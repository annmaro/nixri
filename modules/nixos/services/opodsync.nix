{ ... }:

{
  virtualisation.oci-containers.containers.opodsync = {
    image = "ganeshlab/opodsync:latest";
    ports = [ "8081:8080" ];
    volumes = [
      "/var/lib/opodsync:/var/www/html/data"
    ];
  };

  # Open port 8081 for oPodSync
  networking.firewall.allowedTCPPorts = [ 8081 ];
}
