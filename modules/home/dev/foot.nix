{ config, lib, ... }:

{
  config = lib.mkIf (config.homeSettings.terminal == "foot") {
    programs.foot = {
      enable = true;
      server.enable = true;

      settings = {
        main = {
          font = lib.mkForce "JetBrainsMono Nerd Font:size=14";
          # Stylix supplies the official Gruvbox Material palette for Foot.
          resize-delay-ms = 100; # Reduces sixel image glitching during redraws
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
