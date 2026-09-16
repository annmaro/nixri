{ config, lib, pkgs, ... }:

let
  cfg = config.services.zed-backup;
  zedBackupScript = pkgs.callPackage ../../packages/zed-backup.nix {
    inherit (cfg) interval maxBackups backupDir;
  };
in
{
  options.services.zed-backup = {
    enable = lib.mkEnableOption "Zed editor database background backup daemon";

    interval = lib.mkOption {
      type = lib.types.int;
      default = 120;
      description = "Interval between database backups in seconds.";
    };

    maxBackups = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = 30;
      description = "Max backups to keep per profile (set to null to disable purging).";
    };

    backupDir = lib.mkOption {
      type = lib.types.str;
      default = "~/zed_backups";
      description = "Directory where database snapshots should be stored.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ zedBackupScript ];

    systemd.user.services.zed-backup = {
      description = "Zed Editor Database Auto-Backup Service";
      wantedBy = [ "default.target" ];
      after = [ "default.target" ];

      serviceConfig = {
        ExecStart = "${zedBackupScript}/bin/zed-backup";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
