{
  config,
  lib,
  pkgs,
  wallpaper,
  screenRecorder,
  bar,
}:

let
  inherit (lib) getExe;
  kbdLayout = config.systemSettings.kbdLayout;
  kbdVariant = config.systemSettings.kbdVariant;
  isDms = bar == "DMS";
  accentColor = "#${lib.attrByPath [ "lib" "stylix" "colors" "base0A" ] "d8a657" config}";
  barNamespace = if isDms then "^dms:.*" else "^noctalia:.*";
  restartBar = if isDms then "dms" else "noctalia";
  screenshot = ''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.satty}/bin/satty -f - -o ~/Pictures/Screenshots/satty-%Y%m%d-%H%M%S.png'';
  launcherConfig = "/home/${config.systemSettings.username}/.config/qml-launcher";
  appOpacityRules = [
    {
      matches = [
        { app-id = "^(firefox|floorp|vivaldi-stable|brave-|vlc|easyeffects|gapless)$"; }
      ];
      open-maximized = true;
      draw-border-with-background = false;
      opacity = 1.0;
    }
    {
      matches = [
        { app-id = "^(footclient|foot|yazi|com.mitchellh.ghostty|Alacritty|org.wezfurlong.wezterm)$"; }
      ];
      opacity = 0.80;
      draw-border-with-background = false;
      background-effect = {
        blur = true;
        xray = false;
      };
    }
    {
      matches = [
        {
          app-id = "^(gnome-disks|org.gnome.Nautilus|pcmanfm|file-roller|steamwebhelper|spotify|com.github.th_ch.youtube_music)$";
        }
      ];
      opacity = 0.70;
      draw-border-with-background = false;
      background-effect = {
        blur = true;
        xray = false;
      };
    }
    {
      matches = [
        {
          app-id = "^(Emacs|proton.vpn.app.gtk|heroic|lutris|discord|webcord|vesktop|nvim|nvim-wrapper|antigravity|dev.zed.Zed|code|thunar)$";
        }
      ];
      opacity = 0.85;
      draw-border-with-background = false;
      background-effect = {
        blur = true;
        xray = false;
      };
    }
    {
      matches = [
        { app-id = "mpv"; }
        { app-id = "io.github.celluloid_player.Celluloid"; }
      ];
      open-maximized = true;
    }
    {
      matches = [
        {
          app-id = "^(tmux-sessionizer|pavucontrol|blueman-manager|nm-applet|nm-connection-editor|nwg-look|qt5ct|qt6ct|yad|app.drey.Warp|net.davidotek.pupgui2|Signal|io.gitlab.theevilskeleton.Upscaler|eog)$";
        }
      ];
      open-floating = true;
    }
    {
      matches = [
        { title = "^Picture-in-Picture$"; }
      ];
      open-floating = true;
    }
  ];

  commonBinds = {
    "Mod+Return".spawn = "ghostty";
    "Mod+T".spawn = "footclient";
    "Ctrl+T".spawn = [
      "footclient"
      "-a"
      "tmux-sessionizer"
      "-e"
      "tmux-sessionizer"
    ];
    "Mod+C".spawn = "editor";
    "Mod+F".spawn = "firefox";
    "Mod+A".spawn = "antigravity";
    "Mod+O".toggle-overview = _: { };

    "Mod+G".spawn = [
      "launcher"
      "games"
    ];

    "Alt+F4".close-window = _: { };
    "Ctrl+Q".close-window = _: { };
    "Alt+S".spawn = [
      "systemctl"
      "--user"
      "restart"
      restartBar
    ];
    "Mod+Delete".quit = _: { };
    "Mod+Alt+L".spawn = "swaylock";
    "Mod+Shift+T".spawn-sh = "thunar -q && thunar --daemon";
    "Mod+Ctrl+T".spawn = "Tor Browser";

    "Mod+Shift+R".spawn = [
      (getExe screenRecorder)
      "m"
    ];
    "Mod+Escape".spawn = [
      "pkill"
      "-SIGINT"
      "-x"
      "wf-recorder"
    ];
    "Mod+Shift+S".spawn = "spotify";
    "Mod+Shift+Y".spawn = "youtube-music";
    "Ctrl+Alt+Delete".spawn = [
      "ghostty"
      "-e"
      "btop"
    ];
    "Mod+Ctrl+C".spawn = [
      "hyprpicker"
      "--autocopy"
      "--format=hex"
    ];
    "Mod+F9".spawn-sh = "wlsunset -T 3800 -t 3799";
    "Mod+F10".spawn-sh = "pkill -9 wlsunset || killall -9 wlsunset";

    "Mod+Left".focus-column-left = _: { };
    "Mod+Right".focus-column-right = _: { };
    "Mod+H".focus-column-left = _: { };
    "Mod+L".focus-column-right = _: { };
    "Mod+Ctrl+Left".move-column-left = _: { };
    "Mod+Ctrl+Right".move-column-right = _: { };
    "Mod+Ctrl+K".move-column-to-workspace-up = _: { };
    "Mod+Ctrl+J".move-column-to-workspace-down = _: { };
    "Mod+WheelScrollDown".focus-workspace-down = _: { };
    "Mod+WheelScrollUp".focus-workspace-up = _: { };
    "Mod+Up".focus-window-or-workspace-up = _: { };
    "Mod+Down".focus-window-or-workspace-down = _: { };
    "Mod+Ctrl+Up".move-workspace-up = _: { };
    "Mod+Ctrl+Down".move-workspace-down = _: { };

    "Mod+R".switch-preset-column-width = _: { };
    "Mod+M".maximize-column = _: { };
    "Alt+Return".fullscreen-window = _: { };
    "Mod+Shift+V".toggle-window-floating = _: { };
    "Mod+Equal".set-column-width = "+10%";
    "Mod+Minus".set-column-width = "-10%";
    "Mod+Shift+Minus".set-window-height = "-10%";
    "Mod+Shift+Equal".set-window-height = "+10%";

    "Mod+1".focus-workspace = 1;
    "Mod+2".focus-workspace = 2;
    "Mod+3".focus-workspace = 3;
    "Mod+Shift+1".move-column-to-workspace = 1;
    "Mod+Shift+2".move-column-to-workspace = 2;
    "Mod+Shift+3".move-column-to-workspace = 3;
    "Mod+Shift+4".move-column-to-workspace = 4;
    "Mod+Shift+5".move-column-to-workspace = 5;

    "XF86AudioRaiseVolume".spawn = [
      "pamixer"
      "-i"
      "2"
    ];
    "XF86AudioLowerVolume".spawn = [
      "pamixer"
      "-d"
      "2"
    ];
    "XF86AudioMute".spawn = [
      "pamixer"
      "-t"
    ];
    "XF86AudioMicMute".spawn = [
      "pamixer"
      "--default-source"
      "-t"
    ];
    "XF86MonBrightnessUp".spawn = [
      "brightnessctl"
      "set"
      "+2%"
    ];
    "XF86MonBrightnessDown".spawn = [
      "brightnessctl"
      "set"
      "2%-"
    ];
    "XF86AudioPlay".spawn = [
      "playerctl"
      "play-pause"
    ];
    "XF86AudioPause".spawn = [
      "playerctl"
      "play-pause"
    ];
    "XF86AudioNext".spawn = [
      "playerctl"
      "next"
    ];
    "XF86AudioPrev".spawn = [
      "playerctl"
      "previous"
    ];
    "XF86Sleep".spawn = [
      "systemctl"
      "suspend"
    ];
    "Mod+P".spawn = "keepassxc";
    "Mod+Ctrl+P".spawn-sh = screenshot;
  };
in
{
  prefer-no-csd = _: { };

  hotkey-overlay.skip-at-startup = _: { };

  environment = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland,x11,*";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    OZONE_PLATFORM = "wayland";
    EGL_PLATFORM = "wayland";
    CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    NIXPKGS_ALLOW_UNFREE = "1";
  }
  // lib.optionalAttrs isDms { DMS_DISABLE_MATUGEN = "0"; };

  spawn-sh-at-startup = [
    "sleep 1 && wlsunset -T 3800 -t 3799"
    # Start after Niri has created its outputs. Using the shell startup hook
    # keeps the launcher alive independently of Niri's exec argument parsing.
    "sleep 1 && ${getExe wallpaper}"
    "sleep 2 && thunar --daemon"
  ];

  input = {
    keyboard = {
      xkb = {
        layout = kbdLayout;
        variant = kbdVariant;
      };
      repeat-delay = 275;
      repeat-rate = 35;
      track-layout = "global";
    };
    touchpad.click-method = "clickfinger";
    mouse = {
      accel-profile = "flat";
      accel-speed = 0.0;
    };
    focus-follows-mouse = _: {
      props = {
        max-scroll-amount = "0%";
      };
    };
    warp-mouse-to-focus = _: { };
  };

  outputs."desc:BOE 0x0690" = {
    mode = "1920x1080@60.014";
    scale = 1.0;
    position = _: {
      props = {
        x = 0;
        y = 0;
      };
    };
  };

  workspaces = {
    "1" = _: { };
    "2" = _: { };
  };

  blur = {
    passes = 3;
    offset = 2.0;
    noise = 0.0;
    saturation = 1.0;
  };

  layout = {
    gaps = 8;
    center-focused-column = "never";
    background-color = "transparent";
    focus-ring.off = _: { };
    border = {
      width = 1;
      active-color = accentColor;
      inactive-color = "transparent";
    };
    preset-column-widths = [
      { proportion = 0.33333; }
      { proportion = 0.5; }
      { proportion = 0.66667; }
    ];
  };

  layer-rules = [
    {
      matches = [ { namespace = barNamespace; } ];
      background-effect.xray = false;
    }
    {
      matches = [
        { namespace = "^awww-daemon$"; }
        { namespace = "^mpvpaper$"; }
      ];
      place-within-backdrop = true;
    }
    {
      matches = [
        { namespace = "^qml-launcher$"; }
        { namespace = "^qml-keybinds$"; }
      ];
      background-effect = {
        xray = false;
      };
    }
  ];

  overview.workspace-shadow.off = _: { };

  window-rules = [
    {
      geometry-corner-radius = 12;
      clip-to-geometry = true;
    }
  ]
  ++ appOpacityRules;

  binds =
    commonBinds
    // lib.optionalAttrs isDms {
      "Mod+Q".spawn = [
        "env"
        "QML_XHR_ALLOW_FILE_READ=1"
        "${pkgs.quickshell}/bin/quickshell"
        "--no-duplicate"
        "-p"
        launcherConfig
      ];
      "Mod+K".spawn = [
        "${pkgs.quickshell}/bin/quickshell"
        "--no-duplicate"
        "-p"
        "/home/${config.systemSettings.username}/.config/qml-keybinds"
      ];
      "Mod+N".spawn = [
        "dms"
        "ipc"
        "call"
        "notifications"
        "toggle"
      ];
      "Mod+Shift+E".spawn = [
        "dms"
        "ipc"
        "call"
        "session"
        "toggle"
      ];
      "Mod+Shift+C".spawn = "zededitor";
      "Mod+W".spawn = "waypaper";
      "Mod+S".switch-focus-between-floating-and-tiling = _: { };
    }
    // lib.optionalAttrs (!isDms) {
      "Mod+Space".spawn = [
        "noctalia"
        "toggle"
        "launcher"
      ];
      "Mod+N".spawn = [
        "noctalia"
        "toggle"
        "notifications"
      ];
      "Mod+Shift+E".spawn = [
        "noctalia"
        "toggle"
        "session"
      ];
      "Mod+S".spawn-sh = "niri msg action toggle-overview";
    };
}
