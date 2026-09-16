{ config, ... }:

let
  isBash = config.homeSettings.shell == "bash";
  isZsh = config.homeSettings.shell == "zsh";
in
{
  home.sessionVariables.DIRENV_WARN_TIMEOUT = "60s";

  programs.direnv = {
    enable = true;
    enableBashIntegration = isBash;
    enableZshIntegration = isZsh;
    enableFishIntegration = false;
    enableNushellIntegration = false;
  };
}
