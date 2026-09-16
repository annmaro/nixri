{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "screen-record";

  # Nix securely injects all of these packages into the script's execution path
  runtimeInputs = with pkgs; [
    coreutils    # Provides mkdir, date, basename, etc.
    procps       # Provides pidof, pkill
    libnotify    # Provides notify-send
    slurp        # Provides slurp
    wf-recorder  # Provides wf-recorder
  ];

  text = ''
    XDG_VIDEOS_DIR="''${XDG_VIDEOS_DIR:-$HOME/Videos}"
    DIR="''${XDG_VIDEOS_DIR}/screen-record"

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

    timestamp=$(date +"%Y%m%d_%Hh%Mm%Ss")

    if pidof wf-recorder > /dev/null; then
      pkill wf-recorder
      notify-send -e -t 2500 -u low "Recording Finished" \
        "Saved to $DIR/recording_''${timestamp}.mp4"
      exit 0
    fi

    case "$1" in
      a) REGION=$(slurp) ;;
      m) REGION=$(slurp -o) ;;
      *) print_error ;;
    esac

    notify-send -e -t 2500 -u low "Recording Started"
    wf-recorder -g "$REGION" -f "$DIR/recording_''${timestamp}.mp4"
  '';
}