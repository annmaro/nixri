{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "screen-record";

  runtimeInputs = with pkgs; [
    coreutils
    procps
    libnotify
    slurp
    wf-recorder
  ];

  text = ''
    XDG_VIDEOS_DIR="''${XDG_VIDEOS_DIR:-$HOME/Videos}"
    DIR="''${XDG_VIDEOS_DIR}/screen-record"
    LOCK_FILE="/tmp/screen-record.lock"

    mkdir -p "$DIR"

    print_error() {
      cat <<EOF
    Usage: $(basename "$0") <action>
    Valid actions:
      a  : Select area
      m  : Select monitor
    EOF
      exit 1
    }

    # Stop recording if already running
    if pidof wf-recorder > /dev/null; then
      pkill wf-recorder
      if [ -f "$LOCK_FILE" ]; then
        SAVED_FILE=$(cat "$LOCK_FILE")
        rm -f "$LOCK_FILE"
        notify-send -e -t 2500 -u low "Recording Finished" "Saved to $SAVED_FILE"
      else
        notify-send -e -t 2500 -u low "Recording Finished" "Saved to $DIR"
      fi
      exit 0
    fi

    timestamp=$(date +"%Y%m%d_%Hh%Mm%Ss")
    TARGET_FILE="$DIR/recording_''${timestamp}.mp4"

    case "$1" in
      a)
        # Force slurp to pick even dimensions divisible by 2
        RAW_REGION=$(slurp)
        REGION=$(echo "$RAW_REGION" | awk -F'[@x+]' '{printf "%dx%d+%d+%d", int($1/2)*2, int($2/2)*2, $3, $4}')
        ;;
      m)
        REGION=$(slurp -o)
        ;;
      *)
        print_error
        ;;
    esac

    # Cache target file path for stop notification
    echo "$TARGET_FILE" > "$LOCK_FILE"

    notify-send -e -t 2500 -u low "Recording Started"

    # Hardware-accelerated recording capped at 60fps
    wf-recorder \
      -r 60 \
      -c h264_vaapi \
      -d /dev/dri/renderD128 \
      -g "$REGION" \
      -f "$TARGET_FILE"
  '';
}
