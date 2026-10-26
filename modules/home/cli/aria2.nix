{ pkgs, ... }:

{
  # 1. Install the package so the CLI tool is available anywhere
  home.packages = [ pkgs.aria2 ];

  # 2. Configure the background service
  systemd.user.services.aria2 = {
    Unit = {
      Description = "Aria2 Download Manager Daemon";
      After = [ "network.target" ];
    };
    Service = {
      # Notice we do NOT pass a '--dir' flag here
      ExecStart = "${pkgs.aria2}/bin/aria2c --enable-rpc --rpc-listen-all=false";

      # This ensures the daemon runs out of your home root by default,
      # but won't restrict your manual CLI usage.
      WorkingDirectory = "%h";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
