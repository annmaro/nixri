{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home-manager.sharedModules = [
    (
      { config, ... }:

      let
        # Safe extraction of Stylix colors with a fallback syntax layout
        stylixColors = config.lib.stylix.colors or { };

        bgColor = "#${stylixColors.base00 or "1e1e2e"}"; # Background
        fgColor = "#${stylixColors.base05 or "cdd6f4"}"; # Default Text
        accentColor = "#${stylixColors.base0E or "cba6f7"}"; # Primary Accent (Mauve)
        surfaceMuted = "#${stylixColors.base03 or "45475a"}";

        # Cleaned up payload block: Defined once, inherited for both dark & light modes
        themePayload = {
          background = bgColor;
          backgroundText = fgColor;
          error = "#${stylixColors.base08 or "f38ba8"}";
          info = "#${stylixColors.base0D or "89b4fa"}";
          name = "CatppuccinMocha";
          outline = "#${stylixColors.base04 or "585b70"}";
          primary = accentColor;
          primaryContainer = accentColor;
          primaryText = bgColor;
          secondary = surfaceMuted;
          surface = bgColor;
          surfaceContainer = bgColor;
          surfaceContainerHigh = surfaceMuted;
          surfaceContainerHighest = "#${stylixColors.base04 or "585b70"}";
          surfaceText = fgColor;
          surfaceTint = accentColor;
          surfaceVariant = surfaceMuted;
          surfaceVariantText = fgColor;
          warning = "#${stylixColors.base0A or "f9e2af"}";
        };

        catppuccinMochaTheme = {
          dark = themePayload;
          light = themePayload;
        };
      in
      {
        imports = [
          inputs.dms.homeModules.dank-material-shell
          inputs.dms.homeModules.niri # Enforce native Niri features & auto-spawning
          ./logo.nix # Custom system logo plugin with inline QML for better performance and easier management
        ];

        programs.dank-material-shell = {
          enable = true;
          systemd.enable = true;

          niri = {
            enableKeybinds = false; # Disable DMS's built-in keybinds to prevent conflicts with your custom ones
            enableSpawn = false; # Disable DMS's built-in autostart to prevent conflicts with your custom spawn-at-startup setup
            includes = {
              enable = true;
              # Set override to false so your custom hm.kdl takes priority
              override = false;
              # Exclude colors and layout files so DMS doesn't inject its own window borders
              filesToInclude = [
                "alttab"
                "binds"
                "wpblur"
              ];
            };
          };
        };

        /*
          Clear Out Stale Local DMS Configurations before generating colors from stylix to prevent conflicts and ensure a clean slate for the new theme.
          This is necessary because DMS v6 introduced some changes to how it handles themes and configurations, and old files can cause unexpected behavior if not removed.

          rm -rf ~/.config/niri/dms/colors.kdl
          rm -rf ~/.config/niri/dms/layout.kdl
        */

        home.packages = with pkgs; [
          dgop # Required for DMS system tracking features
          nerd-fonts.jetbrains-mono
          material-symbols
          material-design-icons
        ];

        # =====================================================================
        # 🎨 AUTOMATIC THEME GENERATION
        # =====================================================================
        # Nix now dynamically generates the file using your Stylix palette!
        xdg.configFile."DankMaterialShell/themes/catppuccinMocha/theme.json".text =
          builtins.toJSON catppuccinMochaTheme;
        xdg.configFile."DankMaterialShell/nix.png".source = ./nix.png; # Symlink the local nix.png into the expected path in the home directory for DMS to use as the profile image

        # =====================================================================
        # 🎨 SETTINGS.JSON & SESSION STATE CONFIGURATION
        # =====================================================================

        home.activation.dmsWeather = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          SESSION_FILE="$HOME/.local/state/DankMaterialShell/session.json"
          if [ -f "$SESSION_FILE" ] && [ ! -L "$SESSION_FILE" ]; then
            $DRY_RUN_CMD ${pkgs.jq}/bin/jq '.weatherLocation = "Jharkhand, India" | .weatherCoordinates = "23.63,85.52" | .use24HourClock = true' "$SESSION_FILE" > "$SESSION_FILE.tmp" && \
            $DRY_RUN_CMD mv "$SESSION_FILE.tmp" "$SESSION_FILE"
          elif [ ! -f "$SESSION_FILE" ]; then
            $DRY_RUN_CMD mkdir -p "$HOME/.local/state/DankMaterialShell"
            $DRY_RUN_CMD echo '{"weatherLocation": "Jharkhand, India", "weatherCoordinates": "23.63,85.52", "use24HourClock": true}' > "$SESSION_FILE"
          fi
        '';

        # =====================================================================
        # 🧩 THIRD-PARTY PLUGINS
        # =====================================================================
        # Declaratively install the wallpaperCarousel plugin.
        # Home Manager will automatically symlink this to ~/.config/DankMaterialShell/plugins/wallpaperCarousel

        xdg.configFile."DankMaterialShell/plugins/wallpaperCarousel".source = pkgs.fetchFromGitHub {
          owner = "motor-dev";
          repo = "wallpaperCarousel";
          rev = "main";
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # <-- Replace with the actual hash, or use lib.fakeHash to let Nix tell you the correct one on your first build
        };

        xdg.configFile."DankMaterialShell/settings.json".text = builtins.toJSON {
          configVersion = 18;
          use24HourClock = true;

          wallpaperCarousel = {
            "wallpaperPath": "/home/annmaro/Pictures/Wallpapers";
          };

          screenPreferences = {
            wallpaper = [ ];
          };

          modules = {
            bar = true;
            notifications = true;
            idle = true;
            lockscreen = true;
            wallpaper = false; # false to keep it managed by your separate awww/swaybg
            launcher = false; # Handled by your native rofi setup
            dock = false;
          };

          dynamicTheming = false; # Disable dynamic theming to maintain a consistent look across all widgets, regardless of the current wallpaper or system theme. This ensures that your custom color choices are always applied.
          currentThemeName = "custom"; # Use "custom" to apply your custom theme file specified below
          customThemeFile = "${config.home.homeDirectory}/.config/DankMaterialShell/themes/catppuccinMocha/theme.json"; # Path to your custom theme file, which is generated dynamically from your Stylix palette. Make sure this path matches where your theme file is generated and stored.

          fontFamily = config.stylix.fonts.sansSerif.name;
          monoFontFamily = config.stylix.fonts.monospace.name;

          profileImage = "${config.home.homeDirectory}/.config/DankMaterialShell/nix.png"; # Set the path to your profile image for display in the overview and other DMS components. Make sure the image exists at this location and is in a supported format (e.g., PNG, JPEG).
          launcherLogoMode = "os"; # Set to "os" to display your custom NixOS system logo (SystemLogo.qml) inside the launcher button

          widgetBackgroundColor = "s"; # Use DMS's color tokens for consistent theming
          widgetColorMode = "colorful"; # "colorful" to use theme colors, "default" for a more neutral look
          buttonColorMode = "primary"; # Use primary color for buttons

          popupTransparency = 0.40; # Set popup transparency to create a frosted glass effect for notifications and other popups, allowing the wallpaper to subtly show through while keeping the content readable. Adjust as needed for your preferred balance of visibility and aesthetics.
          cornerRadius = 16; # Apply a consistent border radius to all widgets for a cohesive look

          blurEnabled = true; # Enable blur for overview and other popups
          blurWallpaperOnOverview = true; # Blur the wallpaper when opening the overview for better focus on windows
          blurForegroundLayers = false; # Only blur the background for a cleaner look

          systemTrayIconTintMode = "primary"; # Tint system tray icons with the primary color for a more cohesive look. Adjust as needed based on your custom theme's color palette for optimal aesthetics.
          systemTrayIconTintSaturation = 40; # Increase saturation of tinted system tray icons to make them pop against the background. Adjust as needed based on your custom theme's color palette and desired level of emphasis on the icons.
          systemTrayIconTintStrength = 150; # Increase tint strength for system tray icons to create a more pronounced effect and better integration with the overall theme. Adjust as needed based on your custom theme's color palette and desired level of emphasis on the icons.

          barConfigs = [
            {
              id = "default";
              island = true;
              islandReserveThickness = 31;
              islandCompactThickness = 29;
              islandAlongOffset = 0;
              islandInteractionMode = "hybrid";
              islandTransparency = 0.65;
              islandCornerRadius = 16;
              islandSatellitesEnabled = true;
              islandSatellitePosition = "adjacent";
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

              # Setting bar transparency to 0 hides the background bar background,
              # allowing only the styled widgets to display as floating pill capsules.

              widgetOutlineEnabled = false;
              widgetOutlineColor = "primary";
              widgetOutlineOpacity = 1.0;
              widgetOutlineThickness = 1;
              squareCorners = true;

              fontScale = 1.2;
              iconScale = 1.2;
              transparency = 0.0;
              widgetTransparency = 0.85;

              network_click_action = "applet";
              audio_click_action = "applet";

              leftWidgets = [
                "launcherButton"
                "workspaceSwitcher"
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

          widgets = {
            workspace_switcher = {
              show_labels = false;
              indicator_style = "pill";
            };
          };
        };
      }
    )
  ];
}
