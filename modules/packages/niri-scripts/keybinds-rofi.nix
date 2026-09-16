{ pkgs, ... }:

pkgs.writeShellScriptBin "rofi-keybinds" ''
  NIRI_CONFIG_DIR="$HOME/.config/niri"

  if [ ! -d "$NIRI_CONFIG_DIR" ]; then
      echo "Error: Niri config dir not found at $NIRI_CONFIG_DIR" | ${pkgs.rofi}/bin/rofi -dmenu -p "⚠️ Error"
      exit 1
  fi

  # 1. Grab everything between 'binds {' and the matching '}'
  # 2. Filter out comments, empty lines, and brackets
  # 3. Clean up syntax to look like "Keybind  ->  Action"
  find -L "$NIRI_CONFIG_DIR" -type f -name "*.kdl" -exec cat {} + 2>/dev/null | \
  awk '/binds \{/{flag=1; next} /^\}/{flag=0} flag' | \
  grep -v -E '^[[:space:]]*(//|#|$)' | \
  sed -E 's/^[[:space:]]*"([^"]+)"[[:space:]]*\{[[:space:]]*([^}]+)[[:space:]]*\}/\1  ->  \2/g' | \
  sed -E 's/[";]//g' | \
  sed -E 's/[[:space:]]+$//g' | \
  sed -E 's/[[:space:]]+==>[[:space:]]+/  ->  /g' | \
  ${pkgs.rofi}/bin/rofi -dmenu -i -p "⌨️ Dynamic Keybindings" \
      -theme-str 'window { width: 45%; height: 50%; }' \
      -theme-str 'listview { lines: 20; }'
''
