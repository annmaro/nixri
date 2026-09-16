{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.spoofdpi ];

  systemd.services.spoofdpi = {
    description = "SpoofDPI daemon to bypass SNI filtering";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.spoofdpi}/bin/spoofdpi --listen-addr 127.0.0.1:8080 --dns-mode doh";
      Restart = "always";
      RestartSec = "5";
      DynamicUser = true;
    };
  };
}
