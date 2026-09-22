{ config, ... }:

let
  colors = config.lib.stylix.colors;
  accent = "#${colors.base0A}";
  error = "#${colors.base08}";
  success = "#${colors.base0B}";
  secondary = "#${colors.base0D}";
  muted = "#${colors.base04}";
  info = "#${colors.base0C}";
in
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      scan_timeout = 50;
      format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$python$nix_shell$character";
      directory = {
        truncate_to_repo = false;
        read_only = " ro";
        style = accent;
      };
      character = {
        success_symbol = "[❯](${accent})";
        error_symbol = "[❯](${error})";
        vimcmd_symbol = "[❮](${success})";
      };
      git_branch = {
        format = "[$branch]($style)";
        symbol = "git ";
        style = secondary;
      };
      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](${accent}) ($ahead_behind$stashed)]($style)";
        style = info;
      };
      cmd_duration = {
        format = "[$duration]($style) ";
        style = accent;
      };
      nix_shell = {
        symbol = "❄️ ";
        format = "[$symbol]($style)";
      };
      shell = {
        disabled = false;
        style = info;
        bash_indicator = "";
        powershell_indicator = "";
      };
      python = {
        format = "[$virtualenv]($style) ";
        style = muted;
        symbol = "py ";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = config.homeSettings.shell == "fish";
    enableBashIntegration = config.homeSettings.shell == "bash";
    enableZshIntegration = config.homeSettings.shell == "zsh";
  };
}
