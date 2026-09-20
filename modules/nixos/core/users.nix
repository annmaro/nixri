{ config, inputs, pkgs, ... }:

let
  username = config.systemSettings.username;
  shellPackage = pkgs.${config.systemSettings.shell};
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  programs.dconf.enable = true;

  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "networkmanager"
      "video"
      "audio"
      "libvirtd"
      "kvm"
      "docker"
      "disk"
      "adbusers"
      "lp"
      "scanner"
      "vboxusers"
    ];
    shell = shellPackage;
    ignoreShellProgramCheck = true;
  };

  nix.settings.allowed-users = [ username ];

  home-manager = {
    # Stylix's Home Manager module provides package overlays of its own,
    # so it cannot be combined with useGlobalPkgs = true.
    useGlobalPkgs = false;
    useUserPackages = true;

    # These modules are applied to every Home Manager user. Keeping the
    # feature set here makes additional users reproducible without copying
    # imports into each home-manager.users.<name> block.
    sharedModules = [
      ({ ... }: {
        imports = [ (inputs.import-tree ../../home) ];
      })
    ];

    extraSpecialArgs = {
      inherit inputs;
      systemSettings = config.systemSettings;
    };

    users.${username} = {
      nixpkgs.config.allowUnfree = true;

      homeSettings = {
        username = username;
        gitUsername = config.systemSettings.gitUsername;
        gitEmail = config.systemSettings.gitEmail;
        terminal = config.systemSettings.terminal;
        editor = config.systemSettings.editor;
        browser = config.systemSettings.browser;
        tuiFileManager = config.systemSettings.tuiFileManager;
        shell = config.systemSettings.shell;
        bar = config.systemSettings.bar;
        games = config.systemSettings.games;
      };

      programs.home-manager.enable = true;

      # KeePassXC uses a live rclone mount now.
      
      xdg.enable = true;
      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "26.05";
      };
    };
  };
}
