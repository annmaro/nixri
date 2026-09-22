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

      # 1. Lift deep blacks and soften blown-out whites (matte curve).
      # 2. Shift temperature: boost Red/Green midtones, reduce cold Blues.
      # 3. Blend a Gruvbox luminance duotone map (#1d2021 -> #ebdbb2) over the original.
      # 4. Slightly mute digital saturation (84%) while preserving luminance.
      magick "$INPUT_IMG" \
        +level 4%,96% \
        -channel R -gamma 1.05 +channel \
        -channel B -gamma 0.90 +channel \
        \( +clone +level-colors "#1d2021","#ebdbb2" \) \
        -compose blend -define compose:args=26,74 -composite \
        -modulate 98,84,100 \
        "$OUTPUT_IMG"

      echo "Converted image saved to $OUTPUT_IMG"
    '';
  };
in
{
  home.packages = [ gruvbox-wall ];
}
