# My NixOS Config
{ self, lib, ... }:
let
  vars = import ./variables.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./host-packages.nix

    # Core Modules (Don't change unless you know what you're doing)
    "${self}/modules/core/adblock"
    "${self}/modules/core/boot"
    "${self}/modules/core/bash"
    "${self}/modules/core/fish"
    # "${self}/modules/core/games" # Handled by conditional import at bottom
    "${self}/modules/core/starship"
    "${self}/modules/core/fonts"
    "${self}/modules/core/hardware"
    "${self}/modules/core/memory"
    "${self}/modules/core/network"
    "${self}/modules/core/nh"
    "${self}/modules/core/packages"
    "${self}/modules/core/printing"
    "${self}/modules/core/sddm"
    "${self}/modules/core/security"
    "${self}/modules/core/services"
    "${self}/modules/core/git-sops"
    "${self}/modules/core/spoofdpi"
    "${self}/modules/core/ssh"
    # "${self}/modules/core/syncthing"
    "${self}/modules/core/system"
    "${self}/modules/core/thunar"
    "${self}/modules/core/users"
    "${self}/modules/core/flatpak"
    "${self}/modules/core/xdg"
    "${self}/modules/core/virtualisation"
    # "${self}/modules/core/dlna.nix"

    # Optional
    #"${self}/modules/hardware/drives" # Auto-mounts the internal/external drives
    "${self}/modules/hardware/video/${vars.videoDriver}.nix" # Enable gpu drivers defined in variables.nix
    "${self}/modules/desktop/${vars.desktop}" # Set window manager defined in variables.nix
    "${self}/modules/programs/browser/${vars.browser}" # Set browser defined in variables.nix
    "${self}/modules/programs/terminal/${vars.terminal}" # Set terminal defined in variables.nix
    "${self}/modules/programs/editor/${vars.editor}" # Set editor defined in variables.nix
    "${self}/modules/programs/cli/${vars.tuiFileManager}" # Set file-manager defined in variables.nix
    "${self}/modules/programs/editor/vscode"
    "${self}/modules/programs/editor/antigravity"
    #"${self}/modules/programs/editor/cursor"
    # "${self}/modules/programs/browser/zen"
    "${self}/modules/programs/browser/vimb"
    "${self}/modules/programs/cli/direnv"
    "${self}/modules/programs/terminal/fastfetch"
    "${self}/modules/programs/tuning/cpufreq"
    "${self}/modules/programs/cli/cava"
    "${self}/modules/programs/cli/btop"
    # "${self}/modules/programs/media/discord"
    "${self}/modules/programs/media/spicetify"
    "${self}/modules/programs/media/euphonica"
    "${self}/modules/programs/media/easyeffects"
    "${self}/modules/programs/media/rmpc"
    "${self}/modules/programs/media/rmpd"
    # "${self}/modules/programs/media/youtube-music"
    # "${self}/modules/programs/media/thunderbird"
    # "${self}/modules/programs/media/obs-studio"
    "${self}/modules/programs/media/mpv"
    "${self}/modules/programs/media/rclone"
    "${self}/modules/programs/tuning/tlp"
    # "${self}/modules/programs/tuning/lact" # GPU fan, clock and power configuration
  ]
  ++ lib.optional (vars.games == true) "${self}/modules/core/games";
}
