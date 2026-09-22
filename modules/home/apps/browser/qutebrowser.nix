{
<<<<<<< HEAD
=======
  config,
>>>>>>> fix-nixos-experiment
  pkgs,
  ...
}:

let
  colors = config.lib.stylix.colors;
in
let
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      tldextract
      pyperclip
    ]
  );

in
{
  config = {
    home.packages = with pkgs; [
      qutebrowser
      keyutils
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
<<<<<<< HEAD
      c.colors.statusbar.normal.bg = "#131212"
      c.colors.statusbar.normal.fg = "#bbbbbb"
      c.colors.tabs.bar.bg = "#131212"
      c.colors.tabs.odd.bg = "#1c1b1b"
      c.colors.tabs.even.bg = "#131212"
      c.colors.tabs.selected.odd.bg = "#303030"
      c.colors.tabs.selected.even.bg = "#303030"
      c.colors.tabs.selected.odd.fg = "#b8ddea"
      c.colors.tabs.selected.even.fg = "#b8ddea"
=======
      c.colors.statusbar.normal.bg = "#${colors.base00}"
      c.colors.statusbar.normal.fg = "#${colors.base05}"
      c.colors.tabs.bar.bg = "#${colors.base00}"
      c.colors.tabs.odd.bg = "#${colors.base01}"
      c.colors.tabs.even.bg = "#${colors.base00}"
      c.colors.tabs.selected.odd.bg = "#${colors.base02}"
      c.colors.tabs.selected.even.bg = "#${colors.base02}"
      c.colors.tabs.selected.odd.fg = "#${colors.base0D}"
      c.colors.tabs.selected.even.fg = "#${colors.base0D}"
>>>>>>> fix-nixos-experiment

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

    # Greasemonkey cosmetic ad skip scriptlet
    xdg.dataFile."qutebrowser/greasemonkey/cosmetic-ad-skip.user.js".text = ''
      // ==UserScript==
      // @name         Qutebrowser Cosmetic & YT Skipper
      // @namespace    qutebrowser-custom
      // @match        *://*/*
      // @run-at       document-start
      // ==/UserScript==

      (function() {
          'use strict';

          if (window.location.hostname.includes("youtube.com")) {
              setInterval(() => {
                  const skipButtons = [
                      '.ytp-ad-skip-button-modern',
                      '.ytp-skip-ad-button',
                      '.ytp-ad-skip-button',
                      'button[aria-label^="Skip ad"]'
                  ];

                  for (const selector of skipButtons) {
                      const btn = document.querySelector(selector);
                      if (btn && btn.offsetParent !== null) {
                          btn.click();
                      }
                  }

                  const video = document.querySelector('video');
                  if (video && document.querySelector('.ad-showing, .ad-interrupting')) {
                      if (video.duration && video.currentTime < video.duration - 0.5) {
                          video.currentTime = video.duration - 0.1;
                      }
                  }
              }, 1000);
          }
      })();
    '';
  };
}
