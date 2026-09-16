{ pkgs, ... }:

{
  home-manager.sharedModules = [
    (
      { config, ... }:
      {

        # 1. Configure Swaylock / Swaylock-effects
        programs.swaylock = {
          enable = true;
          # Force home-manager to use the swaylock-effects package for blur features
          package = pkgs.swaylock-effects;

          settings = {
            # Stylix automatically colors the background/indicator, but you can pass extra
            # swaylock-effects arguments here:
            screenshots = true;
            clock = true;
            indicator = true;
            indicator-radius = 100;
            indicator-thickness = 7;
            effect-blur = "7x5"; # Smooth blur effect for behind the lock screen
            effect-vignette = "0.5:0.5";
          };
        };

        # 2. Configure Swayidle (Idling daemon for Niri)
        # 2. Configure Swayidle (Idling daemon for Niri)
        services.swayidle = {
          enable = true;

          # Updated syntax: events is now an attrset keyed by the event name
          events = {
            before-sleep = "${pkgs.swaylock-effects}/bin/swaylock -f";
          };

          timeouts = [
            # Timeout 1: Lock the screen after 10 minutes of inactivity
            {
              timeout = 600;
              command = "${pkgs.swaylock-effects}/bin/swaylock -f";
            }
            # Timeout 2: Turn off the displays via Niri 2 minutes after locking
            {
              timeout = 420;
              command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
              # Turn screens back on when activity is detected
              resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
            }
          ];
        };

      }
    )
  ];
}
