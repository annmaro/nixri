# Dank Material Shell (DMS) Details

**Dank Material Shell (DMS)** is a modern, premium, and Material 3-inspired desktop shell built specifically for Wayland compositors using Quickshell and Go.

In this system configuration, DMS is declared as a flake input from:
> **Source Repository**: `github:AvengeMedia/DankMaterialShell/stable`

Rather than serving as a basic bar, DMS functions as an all-in-one system dashboard, notification hub, lock screen, and session management suite.

---

## Enabled Features & Configuration

All active features of the Dank Material Shell are configured within the modular Nix block under `modules/desktop/niri/dms/default.nix`. By declaring `programs.dank-material-shell.enable = true`, the following selected features have been customized and enabled in this profile:

### 1. Unified Status Bar (`modules.bar = true`)
The shell renders a premium top bar, custom-tailored with the following layout and design variables:

- **Floating Capsule-only Aesthetic**: The main bar transparency is set to `0.0` with widget opacity at `0.85`. Spacing is set to `0`. This effectively hides the background bar, allowing only the styled widgets to display as floating pill capsules.
- **Dynamic Island**: A fully featured dynamic island is enabled (`island = true`) with a "hybrid" interaction mode, transparency of `0.65`, corner radius of `16`, and an adjacent satellite layout. The island home layout contains modules for `media`, `clock`, `weather`, `status`, `volume`, `brightness`, and `notifications`.
- **Minimal Widget Outlines**: Widget outlines are explicitly disabled (`widgetOutlineEnabled = false`) for a cleaner appearance, while still defining properties like a 1px primary-colored outline when outlines might be used elsewhere.
- **Geometric Controls**: The configuration forces `squareCorners = true` to give all corners a classic square shape, overriding any `gothCornersEnabled` parameters.
- **Enhanced Scale**: Fonts and icons are scaled to `1.2` to provide an impactful visual presence and high readability on the bar without being too overwhelming.
- **Minimalist Workspaces**: The workspace switcher (`workspace_switcher`) explicitly hides text labels (`show_labels = false`) and uses a modern "pill" indicator style.
- **Custom Widget Layout**:
  - **Left Area**: `launcherButton` (configured with `launcherLogoMode = "os"` to display a custom inline QML NixOS logo), `workspaceSwitcher`, and `focusedWindow`.
  - **Center Area**: Left empty (`[ ]`), as central widgets are now handled by the dynamic island.
  - **Right Area**: `cpuTemp`, `systemTray`, and `memUsage`.
- **Interactive Applets**: Clicking the network and audio icons automatically triggers their respective system applets (`network_click_action = "applet"`, `audio_click_action = "applet"`).

### 2. Notification Daemon (`modules.notifications = true`)
- Replaces standard standalone notification daemons (like Mako or Dunst) by acting as the system-wide desktop notification server.
- Popups utilize a `0.40` transparency value to create a gorgeous frosted glass look that keeps text perfectly readable while letting background elements bleed through.

### 3. Session & Lock Screen Control (`modules.lockscreen = true` / `modules.idle = true`)
- Enables built-in desktop idle timers and lock screen engines natively integrated with the compositor environment.

### 4. Background & Wallpaper Management (`modules.wallpaper = false`)
- Wallpaper management is explicitly disabled (`modules.wallpaper = false`) to keep backgrounds handled securely by separate external utility wrappers (e.g., awww/swaybg).
- **DMS v6 Compliance**: Incorporates the updated `screenPreferences.wallpaper = [ ]` list syntax, effectively replacing the obsolete `disableWallpaper = true` flag.

### 5. Conflict Resolution & Seamless Niri Integration
- **Keybind & Autostart Decoupling**: Sets `niri.enableKeybinds = false` and `niri.enableSpawn = false` to disable internal DMS hotkeys/launch routines, preserving custom Niri KDL configuration maps.
- **Niri Custom Overrides**: Niri integration includes flag configurations (`includes.enable = true` and `includes.override = false`) ensuring custom `hm.kdl` parameters take absolute priority. It explicitly restricts injected files to `["alttab", "binds", "wpblur"]` to block DMS from pushing unauthorized border styles or layouts.
- **State Cleanup**: Requires manual or scripted clearing of legacy paths (`~/.config/niri/dms/colors.kdl` and `layout.kdl`) to bypass structure conflicts introduced moving into DMS v6.

---

## 🎨 System Theming & Session Initialization

### Automatic Theme Generation
Instead of rigid assets, DMS color management is dynamically constructed directly via Stylix base16 color schemes. Nix transforms these values into a valid Material-compliant JSON tree mapped directly to:
`~/.config/DankMaterialShell/themes/catppuccinMocha/theme.json`

- **Theme Base**: Modeled off a clean CatppuccinMocha structure applied symmetry-wise to both dark and light variations.
- **Dynamic Theming Isolation**: `dynamicTheming` is locked to `false` and `currentThemeName` is forced to `"custom"`. This keeps global palettes locked tightly to your customized Stylix overrides rather than reacting fluidly to changing active wallpapers.
- **System Tray Polish**: System tray icons use `systemTrayIconTintMode = "primary"`, tuned with a saturation metric of `40` and an explicit tint strength of `150` for deep integration into the overall accent aesthetics.
- **UI FX**: Global corner radii are standard locked at `16`. UI elements utilize background blur configurations (`blurEnabled = true` and `blurWallpaperOnOverview = true`) while maintaining sharp foreground layers (`blurForegroundLayers = false`).

### Profile Customization
- **User Avatar**: Implements a dedicated local image file (`./nix.png`) symlinked automatically via Nix into the expected configuration path (`~/.config/DankMaterialShell/nix.png`), feeding directly into the shell dashboard overview profile component.

### Automated Weather Engine State Activation

To circumvent manual dashboard parameter lookup, the environment leverages a Home Manager activation script (`home.activation.dmsWeather`) executing right after filesystem generation (`entryAfter [ "writeBoundary" ]`). The script leverages `jq` to safely initialize or modify the state payload cache inside `~/.local/state/DankMaterialShell/session.json`, locking coordinates and region indicators dynamically.

---

## Packages & Dependencies

To support the complete functionality of this shell, the module declares and installs the following package hooks:

- **`dgop`**: Core system performance-tracking daemon required for real-time CPU/RAM status bar reporting.
- **`jq`**: Lightweight command-line JSON processor leveraged during activation loops to stamp session values safely.
- **`nerd-fonts.jetbrains-mono`**: Premium monospace font applied across text layouts and terminal integrations.
- **`material-symbols` & `material-design-icons`**: Complete modern icon packs utilized by DMS status bar capsules.
