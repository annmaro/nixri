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
    pandoc
    killall
    lm_sensors
    helium
    gnome-disk-utility
    jq
    doggo
    forkstat
    libsecret
    seahorse
    fzf
    fd
    wev
    libinput
    libjxl
    microfetch
    novelwriter
    nix-prefetch-scripts
    ripgrep
    tldr
    rimgo
    unrar
    unzip
    peazip
    calibre
    pdf4qt
    nicotine-plus
    nix-tree
    imagemagickBig
    nomacs
    kid3-qt
    bc
    readest
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
