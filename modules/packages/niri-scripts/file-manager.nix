{ pkgs, terminal, ... }:

pkgs.writeShellApplication {
  name = "file-manager";

  # Nix will safely bundle Thunar and Yazi into the script's execution path
  runtimeInputs = with pkgs; [
    coreutils
    thunar
    yazi
  ];

  text = ''
    case "$1" in
      thunar)
        thunar
        ;;
      yazi)
        ${terminal} --class "fileManager" -e yazi
        ;;
      *)
        echo "Unknown file manager option: $1"
        exit 1
        ;;
    esac
  '';
}