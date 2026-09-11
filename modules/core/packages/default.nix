{ pkgs, inputs, ... }:
{
  # TODO: review
  programs = {
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    appimage-run # Needed For AppImage Support
    killall # For Killing All Instances Of Programs
    lm_sensors # Used For Getting Hardware Temps
    gnome-disk-utility # Disk Partitioning and Mounting Utility
    jq # Json Formatting Utility
    libsecret # Library for storing and retrieving passwords and other secrets
    seahorse # Application for managing encryption keys and passwords in the GnomeKeyring
    fzf # Fuzzy Finder
    fd # Better Find
    wev # Wayland event viewer
    libinput # Handles input devices in Wayland compositors and provides a generic X.Org input driver
    libjxl # Support for JXL Images
    microfetch # Small fetch (Blazingly fast)
    nix-prefetch-scripts # Find Hashes/Revisions of Nix Packages
    ripgrep # Improved Grep
    tldr # Improved Man
    rimgo # Alternative frontend for Imgurss
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    peazip # File and archive manager
    calibre # Comprehensive e-book software
    vivaldi # Browser for our Friends, powerful and personal
    pdf4qt # Open source PDF editor
    nicotine-plus # Graphical client for the SoulSeek peer-to-peer system
    # pay-respects # Magnificent app which corrects your previous console command
    nix-tree # Interactively browse a Nix store paths dependencies
    imagemagickBig # Software suite to create, edit, compose, or convert bitmap images
    nomacs # Qt-based image viewer
    epiphany # WebKit based web browser
    kid3-qt # Simple and powerful audio tag editor
    # digikam # Photo management application
    bc # GNU software calculator
    sox # Sample Rate Converter for audio
    spek # Acoustic spectrum analyser for audio files
    losslessaudiochecker # Utility to check whether audio is truly lossless or not
    qbittorrent # Featureful free software BitTorrent client
    libreoffice-stable # Comprehensive, professional-quality productivity suite
    android-tools # Android SDK platform tools
    vulkan-tools # Khronos official Vulkan Tools and Utilities
    age # Modern encryption tool with small explicit keys
    xdg-utils # Set of command line tools that assist applications with a variety of desktop integration tasks
    eza # Enhanced `ls` command replacement
    tor-browser # Privacy-focused browser routing traffic through the Tor network
    # aider-chat # AI in terminal (Optional: Client only)
    # cmatrix # Matrix Movie Effect In Terminal
    # cowsay # Great Fun Terminal Program
    duf # Utility For Viewing Disk Usage In Terminal
    # dysk # Disk space util nice formattting
    ffmpeg # Terminal Video / Audio Editing
    inxi # CLI System Information Tool
    # libsForQt5.qt5.qtgraphicaleffects # Sddm Dependency (Old)
    # lolcat # Add Colors To Your Terminal Command Output
    lshw # Detailed Hardware Information
    ncdu # Disk Usage Analyzer With Ncurses Interface
    nixfmt # Nix Formatter
    # nwg-displays # configure monitor configs via GUI
    # pavucontrol # For Editing Audio Levels & Devices
    # pciutils # Collection Of Tools For Inspecting PCI Devices
    # picard # For Changing Music Metadata & Getting Cover Art
    # pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
    # socat # Needed For Screenshots
    usbutils # Good Tools For USB Devices
    # uwsm # Universal Wayland Session Manager (optional must be enabled)
    # v4l-utils # Used For Things Like OBS Virtual Camera
    # warp-terminal # Terminal with AI support build in
    wget # Tool For Fetching Files With Links

    # devenv
    # devbox
    # shellify
  ];
}
