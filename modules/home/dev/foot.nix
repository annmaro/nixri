{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.homeSettings.terminal == "foot") {
    programs.foot = {
      enable = true;
      server.enable = true;

      settings = {
        main = {
          font = lib.mkForce "JetBrainsMono Nerd Font:size=14";
          include = "${pkgs.foot.themes}/share/foot/themes/catppuccin-mocha";
        };

        scrollback.lines = 10000;

        bell = {
          urgent = "no";
          notify = "no";
        };

        mouse.hide-when-typing = "yes";

        key-bindings = {
          spawn-terminal = "Control+Alt+n";
          clipboard-copy = "Alt+w";
          clipboard-paste = "Control+y";
        };
      };
    };
  };
}
