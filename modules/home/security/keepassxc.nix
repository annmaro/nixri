{ config, lib, pkgs, ... }:

let
  cfg = config.services.keepassxc-backup;

  backupScript = pkgs.writeShellScript "keepassxc-backup" ''
    set -eu

    vault=${lib.escapeShellArg cfg.vault}
    destination=${lib.escapeShellArg cfg.destination}

    if [ ! -f "$vault" ]; then
      echo "KeePassXC vault does not exist: $vault" >&2
      exit 1
    fi

    # copyto keeps the destination as one current vault rather than creating
    # an unbounded set of timestamped copies on the remote.
    exec ${pkgs.rclone}/bin/rclone copyto "$vault" "$destination" \
      --retries 3 \
      --log-level INFO
  '';
in
{
  options.services.keepassxc-backup = {
    enable = lib.mkEnableOption "periodic KeePassXC vault backups with rclone";

    vault = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Documents/Passwords.kdbx";
      description = "Path to the KeePassXC vault to back up.";
    };

    destination = lib.mkOption {
      type = lib.types.str;
      default = "mydrive:Backups/KeePassXC/Passwords.kdbx";
      description = "Full rclone destination for the KeePassXC vault backup.";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "6h";
      description = "How often the KeePassXC vault backup runs.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.keepassxc = {
      enable = true;
      autostart = true;
      settings = {
        Browser.Enabled = true;
        Browser.UpdateBinaryPath = false;
      };
    };

    xdg.autostart.enable = true;

    home.packages = [ pkgs.rclone ];

    systemd.user.services.keepassxc-backup = {
      Unit = {
        Description = "Back up KeePassXC vault with rclone";
        After = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        EnvironmentFile = config.age.secrets.rclone_gdrive_env.path;
        ExecStart = "${backupScript}";
      };
    };

    systemd.user.timers.keepassxc-backup = {
      Unit.Description = "Periodic KeePassXC vault backup";
      Timer = {
        OnBootSec = "15m";
        OnUnitActiveSec = cfg.interval;
        Persistent = true;
        Unit = "keepassxc-backup.service";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
