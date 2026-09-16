{ config, inputs, pkgs, ... }:

{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

  programs = {
    xfconf.enable = true;
    nix-index-database.comma.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services.xserver = {
    enable = true;
    exportConfiguration = true;
    xkb = {
      layout = config.systemSettings.kbdLayout;
      variant = config.systemSettings.kbdVariant;
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;
    optimise.automatic = true;
    settings = {
      download-buffer-size = 200000000;
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      use-xdg-base-directories = false;
      warn-dirty = false;
      keep-outputs = true;
      keep-derivations = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org/"
        "https://chaotic-nyx.cachix.org/"
        "https://cachix.cachix.org"
        "https://nix-gaming.cachix.org/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };
  };

  time.timeZone = "Asia/Kolkata";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "en_IN/UTF-8" "C.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LC_ADDRESS = "en_IN";
      LC_IDENTIFICATION = "en_IN";
      LC_MEASUREMENT = "en_IN";
      LC_MONETARY = "en_IN";
      LC_NAME = "en_IN";
      LC_NUMERIC = "en_IN";
      LC_PAPER = "en_IN";
      LC_TELEPHONE = "en_IN";
      LC_TIME = "en_IN";
    };
  };

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_BIN_HOME = "$HOME/.local/bin";
    XDG_RUNTIME_DIR = "/run/user/$UID";
  };

  console.keyMap = config.systemSettings.consoleKeymap;
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
