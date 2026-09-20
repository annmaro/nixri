{ config, lib, pkgs, ... }:

let
  comicsMountDir = "${config.home.homeDirectory}/Cloud/Comics";
  passwordsMountDir = "${config.home.homeDirectory}/Cloud/Passwords";
in
{
  home.packages = [
    pkgs.rclone
    pkgs.mcomix
  ];

  home.activation.createMountPoints = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${comicsMountDir}"
    mkdir -p "${passwordsMountDir}"
  '';

  systemd.user.services.rclone-gdrive-comics = {
    Unit = {
      Description = "Optimized Comic-Streaming Cloud Mount for Google Drive";
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "notify";
      EnvironmentFile = config.age.secrets.rclone_gdrive_env.path;
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount mydrive: "${comicsMountDir}" \
          --vfs-cache-mode full \
          --vfs-cache-max-size 15G \
          --vfs-cache-max-age 24h \
          --vfs-read-chunk-size 32M \
          --vfs-read-chunk-size-limit 512M \
          --vfs-read-ahead 128M \
          --buffer-size 32M \
          --dir-cache-time 96h \
          --poll-interval 1m \
          --umask 0022
      '';
      ExecStop = "${pkgs.fuse}/bin/fusermount -u ${comicsMountDir}";
      Restart = "on-failure";
      RestartSec = "10s";
    };

    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.rclone-gdrive-passwords = {
    Unit = {
      Description = "Google Drive Mount for KeePassXC Vault";
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "notify";
      EnvironmentFile = config.age.secrets.rclone_gdrive_env.path;
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount mydrive:Backups/KeePassXC "${passwordsMountDir}" \
          --vfs-cache-mode full \
          --vfs-cache-max-size 1G \
          --vfs-cache-max-age 24h \
          --dir-cache-time 96h \
          --poll-interval 1m \
          --umask 0077
      '';
      ExecStop = "${pkgs.fuse}/bin/fusermount -u ${passwordsMountDir}";
      Restart = "on-failure";
      RestartSec = "10s";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
