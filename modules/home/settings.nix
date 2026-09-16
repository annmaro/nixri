{ config, lib, ... }:

let
  inherit (lib) mkOption types;
in
{
  options.homeSettings = mkOption {
    type = types.submodule {
      options = {
        username = mkOption {
          type = types.str;
          default = "user";
          description = "Home Manager user name.";
        };

        gitUsername = mkOption {
          type = types.str;
          default = "";
          description = "Git author name for this user.";
        };

        gitEmail = mkOption {
          type = types.str;
          default = "";
          description = "Git author email for this user.";
        };

        terminal = mkOption {
          type = types.enum [
            "foot"
            "kitty"
          ];
          default = "foot";
          description = "Default terminal emulator for this user.";
        };

        editor = mkOption {
          type = types.enum [
            "hx"
            "zed"
            "antigravity"
          ];
          default = "hx";
          description = "Default editor for this user.";
        };

        browser = mkOption {
          type = types.enum [
            "firefox"
            "qutebrowser"
            "vimb"
          ];
          default = "firefox";
          description = "Default browser for this user.";
        };

        tuiFileManager = mkOption {
          type = types.enum [
            "yazi"
            "lf"
          ];
          default = "yazi";
          description = "Default terminal file manager for this user.";
        };

        shell = mkOption {
          type = types.enum [
            "bash"
            "zsh"
            "fish"
          ];
          default = "fish";
          description = "Default interactive shell for this user.";
        };

        bar = mkOption {
          type = types.enum [
            "DMS"
            "noctalia"
          ];
          default = "DMS";
          description = "Desktop bar or shell for this user.";
        };

        games = mkOption {
          type = types.bool;
          default = false;
          description = "Whether gaming features are enabled for this user.";
        };
      };
    };
    default = { };
    description = "Per-user Home Manager settings.";
  };

  config =
    let
      editor =
        {
          hx = "hx";
          zed = "zeditor";
          antigravity = "antigravity";
        }
        .${config.homeSettings.editor};
    in
    {
      home.sessionVariables = {
        EDITOR = editor;
        VISUAL = editor;
        BROWSER = config.homeSettings.browser;
        TERMINAL = config.homeSettings.terminal;
      };
    };
}
