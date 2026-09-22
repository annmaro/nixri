{ pkgs, ... }:

let
  gruvbox-wall = pkgs.writeShellApplication {
    name = "gruvbox-wall";

    runtimeInputs = with pkgs; [
      coreutils
      imagemagick
    ];

    text = ''
      if [ "$#" -lt 1 ] || [ -z "$1" ]; then
        echo "Usage: gruvbox-wall <image_path>"
        exit 1
      fi

      INPUT_IMG="$1"
      
      if [ ! -f "$INPUT_IMG" ]; then
        echo "Error: File '$INPUT_IMG' does not exist." >&2
        exit 1
      fi

      CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper"
      OUTPUT_IMG="$CACHE_DIR/gruvbox_$(basename "$INPUT_IMG")"
      mkdir -p "$CACHE_DIR"

      # Keep the source colors while applying a restrained Gruvbox Material
      # grade: a subtle warm-dark tint with slightly muted brightness and color.
      magick "$INPUT_IMG" \
        -fill "#3c3836" -colorize 14% \
        -modulate 96,90,100 \
        "$OUTPUT_IMG"

      echo "Converted image saved to $OUTPUT_IMG"
    '';
  };
in
{
  home.packages = [ gruvbox-wall ];
}
