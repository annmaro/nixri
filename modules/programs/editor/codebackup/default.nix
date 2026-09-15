{ pkgs, ... }:

let
  zedBackupScript = pkgs.writers.writePython3Bin "zed-backup" { } ''
    import os
    import platform
    import shutil
    import sqlite3
    import sys
    import time
    from datetime import datetime
    from pathlib import Path

    BACKUP_INTERVAL = 120
    MAX_BACKUPS_TO_KEEP = 30

    def get_zed_db_paths() -> list[Path]:
        home = Path.home()
        candidates = [
            home / ".local" / "share" / "zed" / "db",
            home / ".var" / "app" / "dev.zed.Zed" / "data" / "zed" / "db",
        ]
        xdg_data = os.environ.get("XDG_DATA_HOME")
        if xdg_data:
            candidates.insert(0, Path(xdg_data) / "zed" / "db")

        found_dbs = []
        for candidate in candidates:
            if candidate.exists():
                for db_file in candidate.rglob("db.sqlite"):
                    found_dbs.append(db_file)
        return found_dbs

    def backup_database(source_db: Path, backup_dir: Path):
        backup_dir.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        channel = source_db.parent.name
        dest_dir = backup_dir / channel
        dest_dir.mkdir(parents=True, exist_ok=True)
        dest_file = dest_dir / f"db_{timestamp}.sqlite"

        src_conn = None
        dest_conn = None
        try:
            src_conn = sqlite3.connect(f"file:{source_db.resolve()}?mode=ro", uri=True)
            dest_conn = sqlite3.connect(dest_file)
            with dest_conn:
                src_conn.backup(dest_conn)
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Backed up: {source_db} -> {dest_file}", flush=True)
        except sqlite3.OperationalError:
            shutil.copy2(source_db, dest_file)
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Copied: {source_db} -> {dest_file}", flush=True)
        finally:
            if src_conn:
                src_conn.close()
            if dest_conn:
                dest_conn.close()

        if MAX_BACKUPS_TO_KEEP:
            existing = sorted(dest_dir.glob("db_*.sqlite"), key=os.path.getmtime)
            while len(existing) > MAX_BACKUPS_TO_KEEP:
                oldest = existing.pop(0)
                try:
                    oldest.unlink()
                except OSError:
                    pass

    def main():
        backup_root = Path.home() / "zed_backups"
        print(f"Starting Zed DB Auto-Backup (Interval: {BACKUP_INTERVAL}s)", flush=True)
        print(f"Target directory: {backup_root}", flush=True)

        try:
            while True:
                target_dbs = get_zed_db_paths()
                if not target_dbs:
                    print(f"[{datetime.now().strftime('%H:%M:%S')}] No Zed database found. Retrying in {BACKUP_INTERVAL}s...", flush=True)
                else:
                    for db_path in target_dbs:
                        backup_database(db_path, backup_root)
                time.sleep(BACKUP_INTERVAL)
        except KeyboardInterrupt:
            print("\nBackup monitor stopped.", flush=True)
            sys.exit(0)

    if __name__ == "__main__":
        main()
  '';
in
{
  # Adds the executable to your user PATH so you can test it directly via CLI
  home.packages = [ zedBackupScript ];

  # Sets up the background user daemon
  systemd.user.services.zed-backup = {
    Unit = {
      Description = "Zed Editor Database Auto-Backup Service";
      After = [ "default.target" ];
    };

    Service = {
      ExecStart = "${zedBackupScript}/bin/zed-backup";
      Restart = "always";
      RestartSec = "10s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
