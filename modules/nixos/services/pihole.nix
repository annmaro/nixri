{ config, inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.secrets.pihole_env.file = ../../../secrets/pihole_env.age;
  age.identityPaths = [ "/home/annmaro/.config/agenix/key.txt" ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers.pihole = {
      autoStart = true;
      image = "pihole/pihole:latest";
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "80:80/tcp"
      ];
      environment = {
        TZ = "UTC";
      };
      environmentFiles = [
        config.age.secrets.pihole_env.path
      ];
      volumes = [
        "/var/lib/pihole/pihole:/etc/pihole"
        "/var/lib/pihole/dnsmasq.d:/etc/dnsmasq.d"
      ];
      extraOptions = [ "--cap-add=NET_ADMIN" ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 80 ];
    allowedUDPPorts = [ 53 ];
  };
}
