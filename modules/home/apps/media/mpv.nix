{ config, pkgs, ... }:

{
  programs.mpv = {
        # Removed Celluloid to ensure custom mpv keyboard shortcuts work perfectly without conflict
        # home.packages = with pkgs; [ celluloid ];

        enable = true;

          # Modern, native, high-performance UI scripts for Wayland
          scripts = with pkgs.mpvScripts; [
            mpris # Essential for MPRIS daemon sync with Niri audio widgets
            thumbfast # Much faster, highly-optimized frame generation tool replacing 'thumbnail'
            uosc # Modern, completely flat, floating context menu and UI for mouse users
          ];

          # Retaining your highly customized keyboard bindings cleanly mapped
          bindings = rec {
            MBTN_LEFT_DBL = "cycle fullscreen";
            MBTN_RIGHT = "cycle pause";
            MBTN_BACK = "playlist-prev";
            MBTN_FORWARD = "playlist-next";
            WHEEL_DOWN = "seek -5";
            WHEEL_UP = "seek 5";
            WHEEL_LEFT = "seek -60";
            WHEEL_RIGHT = "seek 60";

            h = "no-osd seek -5 exact";
            LEFT = h;
            l = "no-osd seek 5 exact";
            RIGHT = l;
            j = "seek -30";
            DOWN = j;
            k = "seek 30";
            UP = k;

            H = "no-osd seek -1 exact";
            "Shift+LEFT" = "no-osd seek -1 exact";
            L = "no-osd seek 1 exact";
            "Shift+RIGHT" = "no-osd seek 1 exact";
            J = "seek -300";
            "Shift+DOWN" = "seek -300";
            K = "seek 300";
            "Shift+UP" = "seek 300";

            "Ctrl+LEFT" = "no-osd sub-seek -1";
            "Ctrl+h" = "no-osd sub-seek -1";
            "Ctrl+RIGHT" = "no-osd sub-seek 1";
            "Ctrl+l" = "no-osd sub-seek 1";
            "Ctrl+DOWN" = "add chapter -1";
            "Ctrl+j" = "add chapter -1";
            "Ctrl+UP" = "add chapter 1";
            "Ctrl+k" = "add chapter 1";

            "Alt+LEFT" = "frame-back-step";
            "Alt+h" = "frame-back-step";
            "Alt+RIGHT" = "frame-step";
            "Alt+l" = "frame-step";

            PGUP = "add chapter 1";
            PGDWN = "add chapter -1";

            u = "revert-seek";

            "Ctrl++" = "add sub-scale 0.1";
            "Ctrl+-" = "add sub-scale -0.1";
            "Ctrl+0" = "set sub-scale 0";

            q = "quit";
            Q = "quit-watch-later";
            "q {encode}" = "quit 4";
            p = "cycle pause";
            SPACE = p;
            f = "cycle fullscreen";

            n = "playlist-next";
            N = "playlist-prev";

            o = "show-progress";
            O = "script-binding stats/display-stats-toggle";
            "`" = "script-binding console/enable";
            ":" = "script-binding console/enable";

            z = "add sub-delay -0.1";
            x = "add sub-delay 0.1";
            Z = "add audio-delay -0.1";
            X = "add audio-delay 0.1";

            "1" = "add volume -1";
            "2" = "add volume 1";
            "Ctrl+s" = ''cycle-values audio-channels "auto-safe" "5.1" "stereo"'';
            v = "cycle video";
            "Ctrl+a" =
              ''cycle-values video-aspect-override "16:9" "4:3" "2.21:1" "2.35:1" "2.39:1" "16:10" "-1"'';
            "Ctrl+S" = ''cycle-values sub-ass-override "force" "no"'';
            PRINT = "screenshot";
            c = "add panscan 0.1";
            C = "add panscan -0.1";
            PLAY = "cycle pause";
            PAUSE = "cycle pause";
            PLAYPAUSE = "cycle pause";
            PLAYONLY = "set pause no";
            PAUSEONLY = "set pause yes";
            STOP = "stop";
            CLOSE_WIN = "quit";
            "CLOSE_WIN {encode}" = "quit 4";
            "Ctrl+w" = ''set hwdec "no"'';

            # Accessing uosc's ultra-clean floating graphical menu
            menu = "script-binding uosc/menu";
          };

          config = {
            # Window Layout Adjustments for Tiling/Niri
            osc = "no";
            border = "no"; # Cleaner framing in structural desktop layouts
            keep-open = "yes"; # Keeps window alive so Niri columns don't instantly shift away
            resume-playback-check-mtime = true;

            # Wayland Hardware & Rendering Optimizations
            vo = "gpu-next"; # Critical modern rendering pipe for flawless Wayland handling
            gpu-context = "wayland"; # Swapped from 'waylandvk' to avoid Vulkan pipeline surface lost bugs on Niri
            hwdec = "auto-safe"; # Zero-copy GPU video rendering to end your stuttering and crashes
            audio-channels = "auto-safe"; # Automatically detects and configures your audio channels for the best experience

            # File Management & Subtitles
            audio-file-auto = "fuzzy";
            sub-auto = "fuzzy";
            wayland-edge-pixels-pointer = 0;
            wayland-edge-pixels-touch = 0;

            # High Quality Screenshots
            screenshot-format = "webp";
            screenshot-webp-lossless = true;
            screenshot-directory = "${config.home.homeDirectory}/Pictures/Screenshots/mpv";
            screenshot-sw = true;
            input-default-bindings = false;
          };
  };
}
