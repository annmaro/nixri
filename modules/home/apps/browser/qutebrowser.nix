{
  config,
  pkgs,
  ...
}:

let
  colors = config.lib.stylix.colors;
in
{
  config = {
    home.packages = with pkgs; [
      qutebrowser
      keyutils
      python3Packages.adblock
    ];


    # Declarative qutebrowser configuration
    xdg.configFile."qutebrowser/config.py".text = ''
      config.load_autoconfig(False)

      # --- Chromium Flags & Engine Workarounds ---
      c.qt.args = [
          "disable-blink-features=AutomationControlled",
          "enable-features=NetworkService,NetworkServiceInProcess"
      ]

      # --- Google Login Spoofing ---
      c.content.headers.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
      c.content.canvas_reading = True
      c.content.webgl = True

      # --- General Settings ---
      c.url.start_pages = ["https://duckduckgo.com"]
      c.url.default_page = "https://duckduckgo.com"
      c.downloads.location.directory = "~/Downloads"
      c.zoom.default = 140

      # --- General Settings ---
      c.url.start_pages = ["https://duckduckgo.com"]
      c.downloads.location.directory = "~/Downloads"
      c.zoom.default = 125
      # Spoof standard Chrome User-Agent and Client Hints
      c.content.headers.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"

      # --- Search Engines ---
      c.url.searchengines = {
          'DEFAULT': 'https://duckduckgo.com/?q={}',
          'g': 'https://www.google.com/search?q={}',
          'y': 'https://www.youtube.com/results?search_query={}',
          'rc': 'https://readallcomics.com',
          'marvel': 'https://comicbookreadingorders.com/marvel/marvel-master-reading-order-part-1',
          'cbh': 'https://www.comicbookherald.com/the-complete-marvel-reading-order-guide',
          'cmro': 'https://marvelreading.com/reading-order/main-616'
      }

      # --- Adblocking Configuration ---
      c.content.blocking.enabled = True
      c.content.blocking.method = "both"
      c.content.javascript.can_open_tabs_automatically = False
      c.content.pdfjs = False
      c.content.blocking.adblock.lists = [
          "https://easylist.to/easylist/easylist.txt",
          "https://easylist.to/easylist/easyprivacy.txt",
          "https://secure.fanboy.co.nz/fanboy-annoyance.txt",
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
      ]

      # --- Native Dark Mode ---
      c.colors.webpage.preferred_color_scheme = "dark"
      c.colors.webpage.darkmode.enabled = True
      c.colors.webpage.darkmode.algorithm = "lightness-cielab"
      c.colors.webpage.darkmode.policy.images = "never"

      # --- UI Dark Theme Colors ---
      c.colors.statusbar.normal.bg = "#${colors.base00}"
      c.colors.statusbar.normal.fg = "#${colors.base05}"
      c.colors.tabs.bar.bg = "#${colors.base00}"
      c.colors.tabs.odd.bg = "#${colors.base01}"
      c.colors.tabs.even.bg = "#${colors.base00}"
      c.colors.tabs.selected.odd.bg = "#${colors.base02}"
      c.colors.tabs.selected.even.bg = "#${colors.base02}"
      c.colors.tabs.selected.odd.fg = "#${colors.base0D}"
      c.colors.tabs.selected.even.fg = "#${colors.base0D}"

      # --- Keybindings ---

      # Raindrop quick action (native bookmark add modal)
      config.bind(',b', 'open https://raindrop.io/add?link={url}', mode='normal')

      # Raindrop Web Clipper Bookmarklet injection
      config.bind(',rb', "open javascript:(function(){var%20e=document.createElement('script');e.setAttribute('type','text/javascript');e.setAttribute('charset','UTF-8');e.setAttribute('src','https://raindrop.io/embed/bookmarklet.js?'+Math.floor(89999999*Math.random()+1e7));document.body.appendChild(e)})();", mode='normal')

      # Toggle dark mode on/off
      config.bind(',td', 'config-cycle colors.webpage.darkmode.enabled true false', mode='normal')

      # Toggle JavaScript execution
      config.bind(',s', 'config-cycle content.javascript.enabled true false', mode='normal')

      # Quickmarks
      config.set('aliases', {
          'raindrop': 'open -t https://app.raindrop.io'
      })
    '';

    # Greasemonkey anti-clickjack, Reddit ad purge, and YouTube ad skipper
    xdg.dataFile."qutebrowser/greasemonkey/cosmetic-ad-skip.user.js".text = ''
      // ==UserScript==
      // @name         Browser Anti-Ad & Clickjack Defuser
      // @namespace    custom
      // @match        *://*/*
      // @run-at       document-start
      // ==/UserScript==

      (function() {
          'use strict';

          const isHost = (domain) => window.location.hostname === domain ||
              window.location.hostname.endsWith('.' + domain);

          // Block external links placed in transparent or unusually high overlays.
          window.addEventListener('click', function(event) {
              const clicked = event.target;
              if (!(clicked instanceof Element)) return;

              const link = clicked.closest('a');
              if (!link) return;

              const href = link.getAttribute('href') || "";
              const style = window.getComputedStyle(link);
              const zIndex = Number.parseInt(style.zIndex, 10);
              const isOverlay = (style.position === 'fixed' || style.position === 'absolute') &&
                  (zIndex > 999 || Number.parseFloat(style.opacity) === 0);

              let destination;
              try {
                  destination = new URL(href, window.location.href);
              } catch (_) {
                  return;
              }

              if (isOverlay && /^https?:$/.test(destination.protocol) &&
                  destination.origin !== window.location.origin) {
                  event.preventDefault();
                  event.stopImmediatePropagation();
                  link.remove();
              }
          }, true);

          // Remove promoted posts as well as hide them before the page is painted.
          if (isHost('reddit.com')) {
              const redditAdSelectors = [
                  'sh-promoted-post',
                  'sh-post[data-promoted="true"]',
                  'sh-post[promoted="true"]',
                  'article[data-ad="true"]',
                  '.promotedlink',
                  '.thing[data-promoted="true"]',
                  'div[data-adclicklocation="ad_post"]',
                  'aside[aria-label="Advertisements"]'
              ];

              const purgeAds = (root) => {
                  if (root instanceof Element && root.matches(redditAdSelectors.join(', '))) {
                      root.remove();
                  }
                  document.querySelectorAll(redditAdSelectors.join(', ')).forEach((node) => node.remove());
              };

              const installRedditFilters = () => {
                  const root = document.documentElement;
                  if (!root) return;

                  if (!document.getElementById('custom-reddit-ad-filter')) {
                      const style = document.createElement('style');
                      style.id = 'custom-reddit-ad-filter';
                      style.textContent = redditAdSelectors.join(', ') +
                          ' { display: none !important; height: 0 !important; }';
                      (document.head || root).appendChild(style);
                  }

                  purgeAds(root);
                  const observer = new MutationObserver((records) => {
                      records.forEach((record) => record.addedNodes.forEach(purgeAds));
                  });
                  observer.observe(root, { childList: true, subtree: true });
              };

              if (document.documentElement) {
                  installRedditFilters();
              } else {
                  document.addEventListener('DOMContentLoaded', installRedditFilters, { once: true });
              }
          }

          // Skip YouTube video ads when a skip button or ad playback is detected.
          if (isHost('youtube.com')) {
              setInterval(() => {
                  const skip = document.querySelector(
                      '.ytp-ad-skip-button-modern, .ytp-skip-ad-button, .ytp-ad-skip-button, button[aria-label^="Skip ad"]'
                  );
                  if (skip && skip.offsetParent !== null) skip.click();

                  const video = document.querySelector('video');
                  if (video && document.querySelector('.ad-showing, .ad-interrupting') &&
                      Number.isFinite(video.duration) && video.duration > 0 &&
                      video.currentTime < video.duration - 0.5) {
                      video.currentTime = video.duration - 0.1;
                  }
              }, 1000);
          }
      })();
    '';
  };
}
