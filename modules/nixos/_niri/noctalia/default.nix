{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  config = lib.mkIf (config.systemSettings.bar == "noctalia") {

  # Enable the NixOS-level services required by Noctalia
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  # Make it a Home Manager module to configure user-specific settings
  home-manager.sharedModules = [
    ({ config, lib, ... }: {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia = {
        enable = true;

        # Configure Noctalia settings natively
        settings = {
          theme = {
            mode = "dark";
            source = lib.mkForce "builtin";
            builtin = "Gruvbox";
          };

          # Date/Time Format Tokens
          shell = {
            time_format = "%I:%M %p"; # 12-hour time with AM/PM
            date_format = "%Y-%m-%d"; # ISO Date format
          };

          # Bar Widgets & Layout
          bar = {
            layout = [
              "workspaces"
              "active_window"
              "spacer"
              "tray"
              "sysmon"
              "weather"
              "clock"
              "control-center"
            ];
          };

          # Location Service
          location = {
            auto_locate = true; # Automatically resolve coordinates from IP address
          };

          # Weather Service
          weather = {
            enabled = true;
            units = "metric"; # Change to imperial if preferred
          };

          # System Monitor Service
          sysmon = {
            enabled = true;
          };

          # Notifications Service
          notifications = {
            enabled = true;
            position = "top-right";
          };
        };
      };
    })
  ];
  };
}
