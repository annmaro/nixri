{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.systemSettings = {
    username = mkOption {
      type = types.str;
      default = "annmaro";
      description = "Primary user login name.";
    };

    gitUsername = mkOption {
      type = types.str;
      default = "annmaro";
      description = "Name used for Git commits.";
    };

    gitEmail = mkOption {
      type = types.str;
      default = "anandk60440@gmail.com";
      description = "Email address used for Git commits.";
    };

    desktop = mkOption {
      type = types.enum [ "niri" ];
      default = "niri";
      description = "Wayland compositor or desktop environment.";
    };

    terminal = mkOption {
      type = types.enum [
        "foot"
        "kitty"
      ];
      default = "foot";
      description = "Default terminal emulator.";
    };

    editor = mkOption {
      type = types.enum [
        "neovim"
        "zed"
        "antigravity"
      ];
      default = "neovim";
      description = "Default text editor executable.";
    };

    browser = mkOption {
      type = types.enum [
        "firefox"
        "qutebrowser"
        "vimb"
        "helium"
      ];
      default = "helium";
      description = "Primary web browser.";
    };

    tuiFileManager = mkOption {
      type = types.enum [
        "yazi"
        "lf"
      ];
      default = "yazi";
      description = "Default terminal file manager.";
    };

    shell = mkOption {
      type = types.enum [
        "bash"
        "zsh"
        "fish"
      ];
      default = "fish";
      description = "Default interactive shell.";
    };

    bar = mkOption {
      type = types.enum [
        "DMS"
        "noctalia"
      ];
      default = "DMS";
      description = "Desktop status bar or shell component.";
    };

    games = mkOption {
      type = types.bool;
      default = false;
      description = "Whether gaming support should be enabled.";
    };

    videoDriver = mkOption {
      type = types.enum [
        "nvidia"
        "amdgpu"
        "intel"
      ];
      default = "intel";
      description = "Primary GPU driver family.";
    };

    hostname = mkOption {
      type = types.str;
      default = "nixri";
      description = "System hostname.";
    };

    clock24h = mkOption {
      type = types.bool;
      default = true;
      description = "Use a 24-hour clock in desktop status components.";
    };

    kbdLayout = mkOption {
      type = types.str;
      default = "us";
      description = "XKB keyboard layout.";
    };

    kbdVariant = mkOption {
      type = types.str;
      default = "";
      description = "XKB keyboard variant.";
    };

    consoleKeymap = mkOption {
      type = types.str;
      default = "us";
      description = "TTY console keymap.";
    };
  };
}
