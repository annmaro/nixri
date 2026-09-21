{
  pkgs,
  ...
}:

let
  vimbWrapped = pkgs.symlinkJoin {
    name = "vimb-wrapped";
    paths = [ pkgs.vimb ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vimb \
        --set GDK_BACKEND "wayland,x11" \
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${pkgs.gst_all_1.gstreamer.out}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-libav}/lib/gstreamer-1.0"
    '';
  };
in
{
  config = {
    home.packages = with pkgs; [
      vimbWrapped
      pinentry-gnome3
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
    ];

    xdg.configFile."vimb/scripts.js".text = ''
      // Vimb Cosmetic Layout Cleaner
      (function() {
          'use strict';
          if (window !== window.top) return;

          const adSelectors = [
              '.adsbox', '.ad-banner', '.adsbygoogle', 'amp-ad',
              'div[id^="div-gpt-ad"]', '.sponsored-post', '#sidebar-ads',
              '.css-1q97669'
          ];

          const style = document.createElement('style');
          style.innerHTML = adSelectors.join(', ') + ' { display: none !important; height: 0 !important; visibility: hidden !important; }';

          const addStyle = () => {
              if (document.head) document.head.appendChild(style);
              else if (document.documentElement) document.documentElement.appendChild(style);
          };

          if (document.readyState === "loading") {
              document.addEventListener('DOMContentLoaded', addStyle);
          } else {
              addStyle();
          }
      })();

      // Anti-Adblock Defuser Scriptlet
      (function() {
          'use strict';
          if (window !== window.top) return;

      // Defuse standard variable checks
        window.canRunAds = true;
        window.isAdBlockActive = false;
        window.adsAreWithUs = true;

      // Mock common Google / general ad objects to trick detection scripts
        if (!window.ga) { window.ga = function() {}; }

      // Prevent common anti-adblock scripts from redefining or crashing on these
        Object.defineProperty(window, 'AdBlock', { value: false, writable: false });
        Object.defineProperty(window, 'snack', { value: { isAdBlockerPresent: function() { return false; } }, writable: false });
      })();

      // YouTube Player Ad Skipper
      (function() {
          'use strict';
          if (window !== window.top) return;

          if (!window.location.hostname.includes("youtube.com")) return;

          function checkAndSkipAds() {
              const skipButtons = [
                  '.ytp-ad-skip-button-modern',
                  '.ytp-skip-ad-button',
                  '.ytp-ad-skip-button',
                  'button[aria-label^="Skip ad"]'
              ];

              for (const selector of skipButtons) {
                  const button = document.querySelector(selector);
                  if (button && button.offsetParent !== null) {
                      button.click();
                  }
              }

              const video = document.querySelector('video');
              if (video && document.querySelector('.ad-showing, .ad-interrupting')) {
                  if (video.duration && video.currentTime < video.duration - 0.5) {
                      video.currentTime = video.duration - 0.1;
                  }
              }
          }

          setInterval(checkAndSkipAds, 1000);
      })();

      // Vimb Clickjack & Popup Blocker
      (function() {
          'use strict';
          // Hook into window.open to stop automated tab hijacking
          const originalWindowOpen = window.open;
          window.open = function(url, name, specs, replace) {
              console.log("Vimb blocked an attempted popup to: " + url);
              // Return a dummy object so the website's script doesn't crash
              return {
                  focus: function() {},
                  blur: function() {},
                  close: function() {},
                  closed: true
              };
          };
      })();

    '';

    # Define the global style.css stylesheet for dark mode
    xdg.configFile."vimb/style.css".text = ''
      *,div,pre,textarea,body,input,td,tr,p {
          background-color: #131212 !important;
          background-image: none !important;
          color: #bbbbbb !important;
      }
      h1,h2,h3,h4 {
          background-color: #303030 !important;
          color: #b8ddea !important;
      }
      a {
          color: #70e070 !important;
      }
      a:hover,a:focus {
          color: #7070e0 !important;
      }
      a:visited {
          color: #e07070 !important;
      }
      img {
          opacity: .5;
      }
    '';

    # Vimb settings
    xdg.configFile."vimb/config".text = ''
      set home-page=https://google.com
      set download-path=~/Downloads/

      # Default Full-Content zoom level in percent. Default is 100.
      set default-zoom=150

      shortcut-default duck
      shortcut-add duck=https://duckduckgo.com/?q=$0
      shortcut-add y=http://www.youtube.com/results?search_query=$0

      shortcut-add rc=https://readallcomics.com
      shortcut-add marvel=https://comicbookreadingorders.com/marvel/marvel-master-reading-order-part-1
      shortcut-add cbh=https://www.comicbookherald.com/the-complete-marvel-reading-order-guide
      shortcut-add cmro=https://marvelreading.com/reading-order/main-616

      autocmd LoadStarted *readallcomics.com set scripts=off

      nmap ,b :open https://raindrop.io/add?link=%
      nmap ,s :set scripts!<CR>
    '';
  };
}
