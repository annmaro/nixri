{ pkgs, ... }:

let
  privoxy-blocklist = pkgs.stdenv.mkDerivation {
    pname = "privoxy-blocklist";
    version = "master";

    src = pkgs.fetchFromGitHub {
      owner = "Andrwe";
      repo = "privoxy-blocklist";
      rev = "master";
      sha256 = "133xch03wqw3bh7j9j849p8znk6cnlhy5jyjwm0my7k4li4zksaa";
    };

    buildInputs = [ pkgs.bash ];
    installPhase = ''
      mkdir -p $out/bin
      cp privoxy-blocklist.sh $out/bin/privoxy-blocklist
      chmod +x $out/bin/privoxy-blocklist
    '';
  };

  whitelist = pkgs.writeText "whitelist.action" ''
    { -block }
    .pixeldrain.com
    .terabox.com
    .teraboxapp.com
    .mediafire.com
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/privoxy-blocklist 0755 privoxy privoxy -"
    "f /var/lib/privoxy-blocklist/user.action 0644 privoxy privoxy - -"
    "f /var/lib/privoxy-blocklist/user.filter 0644 privoxy privoxy - -"
  ];

  services.privoxy = {
    enable = true;
    settings = {
      listen-address = "127.0.0.1:8118";
      actionsfile = [
        "match-all.action"
        "default.action"
        "user.action"
        "/var/lib/privoxy-blocklist/user.action"
        "${whitelist}"
      ];
      filterfile = [
        "default.filter"
        "user.filter"
        "/var/lib/privoxy-blocklist/user.filter"
      ];
    };
  };

  systemd.services.privoxy-blocklist = {
    description = "Update Privoxy blocklists";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [ privoxy-blocklist bash curl wget gawk gnused gnugrep coreutils ];
    serviceConfig = {
      Type = "oneshot";
      User = "privoxy";
      Group = "privoxy";
      StateDirectory = "privoxy-blocklist";
      ExecStart = ''${pkgs.bash}/bin/bash -c "ACTIVATE=0 LISTS_DIR=/var/lib/privoxy-blocklist privoxy-blocklist -A -d /var/lib/privoxy-blocklist -q"'';
      ExecStartPost = "${pkgs.systemd}/bin/systemctl try-reload-or-restart privoxy.service";
    };
  };

  systemd.timers.privoxy-blocklist = {
    description = "Timer for Privoxy blocklist updater";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1w";
      RandomizedDelaySec = "10m";
    };
  };
}
