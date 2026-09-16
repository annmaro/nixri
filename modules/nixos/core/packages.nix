{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs = {
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs; [
    appimage-run
    killall
    lm_sensors
    gnome-disk-utility
    jq
    libsecret
    seahorse
    fzf
    fd
    wev
    libinput
    libjxl
    microfetch
    nix-prefetch-scripts
    ripgrep
    tldr
    rimgo
    unrar
    unzip
    peazip
    calibre
    vivaldi
    pdf4qt
    nicotine-plus
    nix-tree
    imagemagickBig
    nomacs
    epiphany
    kid3-qt
    bc
    sox
    spek
    losslessaudiochecker
    qbittorrent
    libreoffice-stable
    android-tools
    vulkan-tools
    age
    xdg-utils
    eza
    tor-browser
    duf
    ffmpeg
    inxi
    lshw
    ncdu
    nixfmt
    usbutils
    wget
  ];
}
