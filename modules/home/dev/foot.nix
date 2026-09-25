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

        # Larger font profile for dedicated Bookokrat reading windows.
        # Launch with: foot --override=main.font="JetBrains Mono:size=16" bookokrat
        profile-reading = {
          font = "JetBrains Mono:size=16";
        };

        # Optimize Sixel rendering for high-density PDF/DJVU pages in Bookokrat.
        tweak = {
          sixel = "yes";
          max-sixel-dimensions = "4096x4096";
        };
      };
    };
  };
}
