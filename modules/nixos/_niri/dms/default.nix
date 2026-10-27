{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  config = lib.mkIf (config.systemSettings.bar == "DMS") {
    home-manager.sharedModules = [
    (
      { config, lib, ... }:

      let
        # Safe extraction of Stylix colors with a fallback syntax layout
        stylixColors = config.lib.stylix.colors or { };

        bgColor = "#${stylixColors.base00 or "292828"}"; # Gruvbox Material background
        fgColor = "#${stylixColors.base05 or "ddc7a1"}"; # Gruvbox Material default text
        accentColor = "#${stylixColors.base0A or "d8a657"}"; # Gruvbox Material yellow
        surfaceMuted = "#${stylixColors.base03 or "665c54"}";

        # Cleaned up payload block: Defined once, inherited for both dark & light modes
        themePayload = {
          background = bgColor;
          backgroundText = fgColor;
          error = "#${stylixColors.base08 or "ea6962"}";
          info = "#${stylixColors.base0D or "7daea3"}";
          name = "Gruvbox Material";
          outline = "#${stylixColors.base04 or "bdae93"}";
          primary = accentColor;
          primaryContainer = accentColor;
          primaryText = bgColor;
          secondary = surfaceMuted;
          surface = bgColor;
          surfaceContainer = bgColor;
          surfaceContainerHigh = surfaceMuted;
          surfaceContainerHighest = "#${stylixColors.base04 or "bdae93"}";
          surfaceText = fgColor;
          surfaceTint = accentColor;
          surfaceVariant = surfaceMuted;
          surfaceVariantText = fgColor;
          warning = "#${stylixColors.base0A or "d8a657"}";
        };

        gruvboxTheme = {
          dark = themePayload;
          light = themePayload;
        };

        dmsSettingsJson = builtins.toJSON {
          use24HourClock = true;

          screenPreferences = {
            wallpaper = [ ];
          };

          modules = {
            bar = true;
            notifications = true;
            idle = false;
            lockscreen = false;
            wallpaper = false; # The shared Waypaper/mpvpaper switcher owns the backdrop
            launcher = false;
            dock = false;
          };

          dynamicTheming = false; # Disable dynamic theming to maintain a consistent look across all widgets, regardless of the current wallpaper or system theme. This ensures that your custom color choices are always applied.
          currentThemeName = "custom"; # Use "custom" to apply your custom theme file specified below
          customThemeFile = "${config.home.homeDirectory}/.config/dms/themes/gruvbox/theme.json"; # Path to your custom theme file, which is generated dynamically from your Stylix palette. Make sure this path matches where your theme file is generated and stored.

          fontFamily = config.stylix.fonts.sansSerif.name;
          monoFontFamily = config.stylix.fonts.monospace.name;

          profileImage = "file://${config.home.homeDirectory}/.config/dms/nix.png"; # Set the path to your profile image for display in the overview and other DMS components. Make sure the image exists at this location and is in a supported format (e.g., PNG, JPEG).

          widgetBackgroundColor = "s"; # Use DMS's color tokens for consistent theming
          widgetColorMode = "colorful"; # "colorful" to use theme colors, "default" for a more neutral look
          buttonColorMode = "primary"; # Use primary color for buttons

          popupTransparency = 0.58; # Surface opacity set to 58%
          radiusMode = "scale"; # Material scale corner style
          radiusStrength = 50; # 50 = Material 3 shape scale strength

          blurEnabled = true; # Enable blur for overview and other popups
          blurWallpaperOnOverview = true; # Blur the wallpaper when opening the overview for better focus on windows
          blurForegroundLayers = false; # Only blur the background for a cleaner look

          systemTrayIconTintMode = "primary"; # Tint system tray icons with the primary color for a more cohesive look. Adjust as needed based on your custom theme's color palette for optimal aesthetics.
          systemTrayIconTintSaturation = 40; # Increase saturation of tinted system tray icons to make them pop against the background. Adjust as needed based on your custom theme's color palette and desired level of emphasis on the icons.
          systemTrayIconTintStrength = 150; # Increase tint strength for system tray icons to create a more pronounced effect and better integration with the overall theme. Adjust as needed based on your custom theme's color palette and desired level of emphasis on the icons.

          dashCards = [
            {
              id = "clock";
              w = 1;
              h = 2;
              col = 0;
              row = 0;
            }
            {
              id = "calendar";
              w = 3;
              h = 3;
              col = 0;
              row = 2;
            }
            {
              id = "media";
              w = 3;
              h = 5;
              col = 3;
              row = 0;
            }
            {
              id = "sysmon";
              w = 2;
              h = 1;
              col = 1;
              row = 1;
            }
            {
              id = "weather";
              w = 2;
              h = 1;
              col = 1;
              row = 0;
            }
          ];

          dashOptions = {
           weather = {
           panelColumns = 5;
           }
           };

          barConfigs = [
            {
              id = "default";
              island = true;
              islandReserveThickness = 31;
              islandCompactThickness = 29;
              islandAlongOffset = 0;
              islandInteractionMode = "hybrid";
              islandSatellitesEnabled = true;
              islandSatellitePosition = "island"; # "island" = Near island ("edges" = Display edges)
              islandPalette = "dim";
              islandSatelliteGap = 4;
              islandHomeClockDisplay = "both";
              islandHomeVolumeDisplay = "both";
              islandHomeBrightnessDisplay = "both";
              islandHomeLayout = [
                {
                  id = "media";
                  enabled = true;
                }
                {
                  id = "clock";
                  enabled = true;
                }
                {
                  id = "weather";
                  enabled = true;
                }
                {
                  id = "status";
                  enabled = true;
                }
                {
                  id = "volume";
                  enabled = true;
                }
                {
                  id = "brightness";
                  enabled = true;
                }
                {
                  id = "notifications";
                  enabled = true;
                }
              ];
              name = "Main Bar";
              enabled = true;
              position = "top";
              spacing = 0; # Space between the bar and screen edges

              # Main Bar surface opacity override to 58%
              transparency = 0.58;
              followInterfaceStyle = false;

              # Widget styling and opacity override to 58%
              widgetStyle = "pills";
              noBackground = false;
              widgetFollowInterfaceStyle = false; # Overrides interface style for widget opacity
              widgetTransparency = 0.58; # 58% widget opacity

              widgetOutlineEnabled = false;
              widgetOutlineColor = "primary";
              widgetOutlineOpacity = 1.0;
              widgetOutlineThickness = 1;
              squareCorners = true;

              fontScale = 1.2;
              iconScale = 1.2;

              network_click_action = "applet";
              audio_click_action = "applet";

              leftWidgets = [
                {
                  id = "launcherButton";
                  launcherLogoMode = "os";
                }
                {
                  id = "workspaceSwitcher";
                  workspaceIndicatorStyle = "pills";
                  showWorkspaceIndex = false;
                  showWorkspaceName = false;
                }
                "focusedWindow"
              ];
              centerWidgets = [ ];
              rightWidgets = [
                "cpuTemp"
                "systemTray"
                "memUsage"
              ];
            }
          ];
        };
      in
      {
        imports = [
          (inputs.dms.homeModules.default or inputs.dms.homeModules.dank-material-shell)
          inputs.niri.homeModules.niri
          ./logo.nix # Custom system logo plugin with inline QML for better performance and easier management
        ];

        # DMS currently declares Niri settings; import the schema only so
        # Home Manager can type-check those settings without managing Niri's
        # config file. The system-level wrapper owns the actual Niri config.
        programs.niri.config = null;

        programs.dank-material-shell = {
          enable = true;
          systemd.enable = true;
        };

        /*
          Clear Out Stale Local DMS Configurations before generating colors from stylix to prevent conflicts and ensure a clean slate for the new theme.
          This is necessary because DMS v6 introduced some changes to how it handles themes and configurations, and old files can cause unexpected behavior if not removed.

          rm -rf ~/.config/niri/dms/colors.kdl
          rm -rf ~/.config/niri/dms/layout.kdl
        */

        home.packages = with pkgs; [
          dux-gop # Required for DMS system tracking features
          nerd-fonts.jetbrains-mono
          material-symbols
          material-design-icons
        ];

        # =====================================================================
        # 🎨 AUTOMATIC THEME GENERATION
        # =====================================================================
        # Nix dynamically generates the theme file using your Stylix palette!
        # Write to both modern ~/.config/dms and legacy ~/.config/DankMaterialShell paths
        xdg.configFile."dms/themes/gruvbox/theme.json".text =
          builtins.toJSON gruvboxTheme;
        xdg.configFile."DankMaterialShell/themes/gruvbox/theme.json".text =
          builtins.toJSON gruvboxTheme;
        xdg.configFile."dms/nix.png".source = ./nix.png;
        xdg.configFile."DankMaterialShell/nix.png".source = ./nix.png;

        # =====================================================================
        # 🎨 SETTINGS.JSON & SESSION STATE CONFIGURATION
        # =====================================================================

        home.activation.dmsWeather = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          for STATE_DIR in "$HOME/.local/state/dms" "$HOME/.local/state/DankMaterialShell"; do
            SESSION_FILE="$STATE_DIR/session.json"
            if [ -f "$SESSION_FILE" ] && [ ! -L "$SESSION_FILE" ]; then
              $DRY_RUN_CMD ${pkgs.jq}/bin/jq '.weatherLocation = "Jharkhand, India" | .weatherCoordinates = "23.63,85.52" | .use24HourClock = true' "$SESSION_FILE" > "$SESSION_FILE.tmp" && \
              $DRY_RUN_CMD mv "$SESSION_FILE.tmp" "$SESSION_FILE"
            elif [ ! -f "$SESSION_FILE" ]; then
              $DRY_RUN_CMD mkdir -p "$STATE_DIR"
              $DRY_RUN_CMD echo '{"weatherLocation": "Jharkhand, India", "weatherCoordinates": "23.63,85.52", "use24HourClock": true}' > "$SESSION_FILE"
            fi
          done
        '';

        # =====================================================================
        # 🧩 SETTINGS CONFIGURATION
        # =====================================================================
        # Deploy settings to both modern dms and legacy DankMaterialShell paths
        xdg.configFile."dms/settings.json" = {
          force = true;
          text = dmsSettingsJson;
        };

        xdg.configFile."DankMaterialShell/settings.json" = {
          force = true;
          text = dmsSettingsJson;
        };
      }
    )
    ];
  };
}
