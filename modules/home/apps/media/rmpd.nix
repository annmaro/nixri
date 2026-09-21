{ config, pkgs, ... }:

let
  rmpd = pkgs.callPackage ../../../packages/rmpd.nix { };
in
{
  home.packages = [ rmpd ];

  xdg.configFile."rmpd/rmpd.toml".text = ''
    [general]
    music_directory = "${config.home.homeDirectory}/Music"
    log_level = "info"

    [network]
    port = 6600
    mpris = false

    [audio]
    default_output = "pipewire"
    replay_gain = "off"

    [[output]]
    name = "PipeWire Sound Server"
    type = "pipewire"
    resampler_quality = 0
  '';

  systemd.user.services.rmpd = {
    Unit = {
      Description = "rmpd - Rust Music Player Daemon";
      After = [ "network.target" "pipewire.service" ];
    };

    Service = {
      ExecStart = "${rmpd}/bin/rmpd";
      Restart = "always";
    };

    Install.WantedBy = [ "default.target" ];
  };

  services.mpdris2 = {
    enable = true;
    mpd.musicDirectory = "${config.home.homeDirectory}/Music";
  };
}
