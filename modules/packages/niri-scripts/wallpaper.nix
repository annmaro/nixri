{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "niri-wallpaper";

  runtimeInputs = with pkgs; [
    coreutils
    procps
    awww
    mpvpaper
  ];

  text = ''
    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper"
    LAST_WALL="$CACHE_DIR/last_wallpaper"
    WAYPAPER_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/waypaper/config.ini"
    # Support multiple possible video wallpaper locations
    VIDEO_WALL_CANDIDATES=(
      "$HOME/Pictures/Wallpapers/output.mp4"
      "$HOME/Pictures/Wallpapers/output_1080p.mp4"
    )
    mkdir -p "$CACHE_DIR"

    # Clean up hooks from the old Waypaper configuration. That hook decoded the
    # video indefinitely with ImageMagick/ffmpeg and could leave many workers.
    pkill -f 'magick .*niri-overview-blurred' 2>/dev/null || true
    pkill -f 'ffmpeg.*magick-' 2>/dev/null || true

    # Waypaper runs this as its post-command. Its current selection is written
    # to config.ini, so the same command also works when called by Niri startup.
    if [ "$#" -ge 1 ] && [ -n "$1" ] && [ "$1" != "\$wallpaper" ]; then
      TARGET_WALL="$1"
    elif [ -f "$LAST_WALL" ]; then
      TARGET_WALL="$(cat "$LAST_WALL")"
    elif [ -f "$WAYPAPER_CONFIG" ]; then
      TARGET_WALL="$(sed -n 's/^wallpaper[[:space:]]*=[[:space:]]*//p' "$WAYPAPER_CONFIG" | tail -n 1)"
    else
      # Find first existing video wallpaper candidate
      TARGET_WALL=""
      for candidate in "''${VIDEO_WALL_CANDIDATES[@]}"; do
        if [ -f "$candidate" ]; then
          TARGET_WALL="$candidate"
          break
        fi
      done
      # Fallback to first candidate even if it doesn't exist yet
      [ -z "$TARGET_WALL" ] && TARGET_WALL="''${VIDEO_WALL_CANDIDATES[0]}"
    fi

    if [ -z "$TARGET_WALL" ]; then
      TARGET_WALL="''${VIDEO_WALL_CANDIDATES[0]}"
    fi

    # Waypaper accepts a tilde in config.ini, but shell variables do not
    # perform tilde expansion after command substitution.
    case "$TARGET_WALL" in
      ~/*) TARGET_WALL="$HOME/''${TARGET_WALL#~/}" ;;
    esac

    case "$TARGET_WALL" in
      *.mp4|*.webm|*.mkv|*.mov)
        if [ ! -f "$TARGET_WALL" ]; then
          echo "Error: video wallpaper '$TARGET_WALL' does not exist." >&2
          exit 1
        fi
        pkill -x awww-daemon 2>/dev/null || true
        pkill -x mpvpaper 2>/dev/null || true
        printf '%s\n' "$TARGET_WALL" > "$LAST_WALL"
        # Keep mpvpaper on the normal background layer. Niri's layer rule
        # places that surface behind windows and inside the overview backdrop.
        mpvpaper \
          --fork \
          --layer background \
          -o 'no-audio --loop-file=inf --cache=no --demuxer-readahead-secs=1 --hwdec=auto' \
          ALL "$TARGET_WALL" >"$CACHE_DIR/mpvpaper.log" 2>&1
        ;;
      *)
        if [ ! -f "$TARGET_WALL" ]; then
          echo "Error: wallpaper '$TARGET_WALL' does not exist." >&2
          exit 1
        fi
        pkill -x mpvpaper 2>/dev/null || true
        if pgrep -x awww-daemon >/dev/null 2>&1; then
          # Check if daemon is responding (might be from an old session)
          if ! awww query >/dev/null 2>&1; then
            pkill -x awww-daemon 2>/dev/null || true
            sleep 0.2
          fi
        fi
        if ! pgrep -x awww-daemon >/dev/null 2>&1; then
          awww-daemon >"$CACHE_DIR/awww-daemon.log" 2>&1 &
          sleep 0.5
        fi
        printf '%s\n' "$TARGET_WALL" > "$LAST_WALL"
        awww img "$TARGET_WALL" \
          --transition-type grow \
          --transition-pos center \
          --transition-duration 1.2 \
          --transition-fps 120
        ;;
    esac
  '';
}
