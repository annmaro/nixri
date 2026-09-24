{
  config,
  pkgs,
  ...
}:

let
  colors = config.lib.stylix.colors;
in

let
  vimbWrapped = pkgs.symlinkJoin {
    name = "vimb-wrapped";
    paths = [ pkgs.vimb ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vimb \
        --set GDK_BACKEND "wayland,x11" \
        --set GTK_THEME "Adwaita:dark" \
        --set ADW_DEBUG_COLOR_SCHEME "prefer-dark" \
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
      // Cosmetic ad filters and dynamic Reddit promoted-post cleanup
      if (window.location.hostname.includes("cloudflare.com") ||
          document.title.includes("Just a moment") ||
          document.title.includes("Security Check")) {
          return;
      }
      (function() {
          'use strict';
          if (window !== window.top) return;

          const adSelectors = [
              '.adsbox', '.ad-banner', '.adsbygoogle', 'amp-ad',
              'div[id^="div-gpt-ad"]', '.sponsored-post', '#sidebar-ads'
          ];
          const isReddit = window.location.hostname === 'reddit.com' ||
              window.location.hostname.endsWith('.reddit.com');
          const redditAdSelectors = [
              'sh-promoted-post',
              'sh-post[data-promoted="true"]',
              'sh-post[promoted="true"]',
              'article[data-ad="true"]',
              '.promotedlink',
              '.thing[data-promoted="true"]',
              'div[data-adclicklocation="ad_post"]',
              'aside[aria-label="Advertisements"]',

          ];
          const selectors = isReddit ? adSelectors.concat(redditAdSelectors) : adSelectors;

          const addStyle = () => {
              const root = document.documentElement;
              if (!root) return;

              if (!document.getElementById('vimb-ad-filter')) {
                  const style = document.createElement('style');
                  style.id = 'vimb-ad-filter';
                  style.textContent = selectors.join(', ') +
                      ' { display: none !important; height: 0 !important; visibility: hidden !important; }';
                  (document.head || root).appendChild(style);
              }

              if (!isReddit) return;

              const purgeAds = (node) => {
                  if (node instanceof Element && node.matches(redditAdSelectors.join(', '))) {
                      node.remove();
                  }
                  document.querySelectorAll(redditAdSelectors.join(', ')).forEach((ad) => ad.remove());
              };
              purgeAds(root);

              const observer = new MutationObserver((records) => {
                  records.forEach((record) => record.addedNodes.forEach(purgeAds));
              });
              observer.observe(root, { childList: true, subtree: true });
          };

          if (document.documentElement) {
              addStyle();
          } else {
              document.addEventListener('DOMContentLoaded', addStyle, { once: true });
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

          window.open = function(url) {
              console.warn('Vimb blocked an attempted popup to:', url);
              return {
                  focus: function() {},
                  blur: function() {},
                  close: function() {},
                  closed: true
              };
          };

          window.addEventListener('click', function(event) {
              let node = event.target;
              while (node && node !== document.body) {
                  if (node instanceof Element && node.tagName === 'A' &&
                      node.getAttribute('target') === '_blank') {
                      const style = window.getComputedStyle(node);
                      const zIndex = Number.parseInt(style.zIndex, 10);
                      const suspiciousLayer =
                          (style.position === 'fixed' || style.position === 'absolute') &&
                          (zIndex >= 100 || Number.parseFloat(style.opacity) === 0);

                      let destination;
                      try {
                          destination = new URL(node.getAttribute('href') || "", window.location.href);
                      } catch (_) {
                          return;
                      }

                      if (suspiciousLayer && /^https?:$/.test(destination.protocol) &&
                          destination.origin !== window.location.origin) {
                          event.preventDefault();
                          event.stopImmediatePropagation();
                          node.remove();
                          console.warn('Vimb blocked a clickjack overlay:', node);
                          return;
                      }
                  }
                  node = node.parentElement;
              }
          }, true);
      })();

    '';

    # Define the global style.css stylesheet for dark mode
    xdg.configFile."vimb/style.css".text = ''
          /* 1. Clear body background image (removes diamond pattern/gradients) */
          html, body {
              background: #${colors.base00} !important;
              background-color: #${colors.base00} !important;
              background-image: none !important;
              color: #${colors.base05} !important;
          }

          /* 2. Force containers, tables, and forum blocks to adopt base dark colors */
          div, main, article, section, header, footer, nav, aside,
          table, thead, tbody, tfoot, tr, td, th,
          ul, ol, li, dl, dt, dd {
              background-color: #${colors.base00} !important;
              background-image: none !important;
              color: #${colors.base05} !important;
              border-color: #${colors.base02} !important;
          }

          /* 3. Text and Headings */
          h1, h2, h3, h4, h5, h6 {
              color: #${colors.base0D} !important;
              background-color: transparent !important;
          }
          p, span, label {
              color: #${colors.base05} !important;
          }

          /* 4. Links */
          a, a * {
              color: #${colors.base0C} !important;
          }
          a:hover, a:focus, a:hover *, a:focus * {
              color: #${colors.base0A} !important;
          }
          a:visited, a:visited * {
              color: #${colors.base08} !important;
          }

          /* 5. Form controls and Code blocks */
          input, textarea, select, button, pre, code {
              background-color: #${colors.base01} !important;
              background-image: none !important;
              color: #${colors.base05} !important;
              border: 1px solid #${colors.base03} !important;
          }

          /* 6. Preserve media, comic covers, and badges */
          img, svg, video, canvas, picture,
          [class*="cover"], [class*="avatar"], [class*="badge"] {
              background-color: transparent !important;
          }
          /* Vimb Hint Badges (the number boxes) */
          span[vimbhint^='label'] {
              background-color: #${colors.base01} !important;  /* Dark grey */
              color: #${colors.base05} !important;            /* Light grey text */
              border: 1px solid #${colors.base03} !important; /* Muted border */
              font-weight: bold !important;
              border-radius: 2px !important;
              padding: 1px 3px !important;
          }

          /* Focused Hint Badge (the active number box) */
          span[vimbhint='label focus'] {
              background-color: #${colors.base02} !important;
              color: #${colors.base0B} !important;
          }

          /* Vimb Hinted Elements (the highlighted links - replaces the bright yellow!) */
          *[vimbhint^='hint'] {
              background-color: #${colors.base0B} !important;  /* Stylix Green */
              color: #${colors.base00} !important;            /* High contrast text */
          }

          /* Vimb Focused Hint Element (the currently selected target) */
          *[vimbhint='hint focus'] {
              background-color: #${colors.base01} !important;
              color: #${colors.base0B} !important;
              outline: 2px solid #${colors.base0B} !important;
          }
        '';
    # Vimb settings
    xdg.configFile."vimb/config".text = ''
      set home-page=https://google.com
      set download-path=~/Downloads/
      set stylesheet=true
      set javascript-can-open-windows-automatically=false

      # Accept all cookies or only first-party + visited third-party
      set cookie-accept=all

      # Set custom user-agent
      set user-agent=Mozilla/5.0 (X11; Linux x86_64; rv:135.0) Gecko/20100101 Firefox/135.0

      # Default Full-Content zoom level in percent. Default is 100.
      set default-zoom=140

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
