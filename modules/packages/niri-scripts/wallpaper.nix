{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "wallpaper";

  runtimeInputs = with pkgs; [
    coreutils # Provides sleep, cat, mkdir, dirname
    procps # Provides pgrep
    awww # Provides awww-daemon, awww
  ];

  text = ''
    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper"
    LAST_WALL="$CACHE_DIR/last_wallpaper"
    mkdir -p "$CACHE_DIR"

    # 1. Ensure awww-daemon is running
    if ! pgrep -f "awww-daemon$" > /dev/null 2>&1; then
      awww-daemon &
      sleep 0.5
    fi

    # 2. Handler: Setting a wallpaper (called with an image path argument)
    if [ "$#" -ge 1 ] && [ -n "$1" ]; then
      TARGET_IMG="$1"

      if [ ! -f "$TARGET_IMG" ]; then
        echo "Error: File '$TARGET_IMG' does not exist." >&2
        exit 1
      fi

      # Save current selection for session restore
      echo "$TARGET_IMG" > "$LAST_WALL"

      # Transition animation parameters:
      # Types supported by awww include: fade, wipe, grow, wave, outer
      exec awww load "$TARGET_IMG" \
        --transition-type grow \
        --transition-pos center \
        --transition-duration 1.2 \
        --transition-fps 120

    # 3. Handler: Session boot / restore (called without arguments)
    else
      if [ -f "$LAST_WALL" ]; then
        RESTORE_IMG="$(cat "$LAST_WALL")"
        if [ -f "$RESTORE_IMG" ]; then
          exec awww load "$RESTORE_IMG" --transition-type fade --transition-duration 0.5
        fi
      fi
    fi
  '';
}
