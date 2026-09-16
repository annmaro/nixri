{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "screenshot";

  # Nix securely injects these specific utilities directly into the script's execution PATH
  runtimeInputs = with pkgs; [
    coreutils    # Provides mkdir, date, basename
    grimblast    # Provides screenshot backend
    swappy       # Provides image editing/annotation GUI
    libnotify    # Provides notify-send
  ];

  text = ''
    # shellcheck disable=SC2155

    swpy_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/swappy"
    XDG_PICTURES_DIR="''${XDG_PICTURES_DIR:-$HOME/Pictures}"
    save_dir="''${XDG_PICTURES_DIR}/Screenshots"

    mkdir -p "$save_dir"
    mkdir -p "$swpy_dir"

    print_error() {
      cat << EOF
    Usage: $(basename "$0") <action>
    Valid actions:
      p  : Print all screens
      s  : Snip area
      sf : Snip area (frozen)
      m  : Print focused monitor
    EOF
      exit 1
    }

    take_screenshot() {
      # Separating declaration and assignment to satisfy ShellCheck rule checks
      local save_file
      save_file="$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')"

      cat > "$swpy_dir/config" << EOF
    [Default]
    save_dir=$save_dir
    save_filename_format=$save_file
    EOF

      case "$1" in
        screen) grimblast save screen - | swappy -f - ;;
        area)   grimblast save area - | swappy -f - ;;
        freeze) grimblast --freeze save area - | swappy -f - ;;
        output) grimblast save output - | swappy -f - ;;
      esac

      if [ -f "''${save_dir}/''${save_file}" ]; then
        notify-send -a Screenshot \
                    -i "''${save_dir}/''${save_file}" \
                    "Screenshot Saved" \
                    "$(basename "$save_file")"
      fi
    }

    case "$1" in
      p)  take_screenshot screen ;;
      s)  take_screenshot area ;;
      sf) take_screenshot freeze ;;
      m)  take_screenshot output ;;
      *)  print_error ;;
    esac
  '';
}