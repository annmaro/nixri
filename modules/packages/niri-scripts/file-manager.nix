{ pkgs, terminal, ... }:

pkgs.writeShellApplication {
  name = "file-manager";

  # Nix will safely bundle Thunar and Superfile into the script's execution path
  runtimeInputs = with pkgs; [
    coreutils
    thunar
    superfile
  ];

  text = ''
    case "$1" in
      thunar)
        thunar
        ;;
      superfile|spf)
        ${terminal} --class "fileManager" -e superfile
        ;;
      *)
        echo "Unknown file manager option: $1"
        exit 1
        ;;
    esac
  '';
}