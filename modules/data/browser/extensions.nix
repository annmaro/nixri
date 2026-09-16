{ lib, config, ... }:
{
  nav-bar = [
    "_c4b582ec-4343-438c-bda2-2f691c16c262_-browser-action"
    "firemonkey_eros_man-browser-action"
    "ublock0_raymondhill_net-browser-action"
    # "addon_darkreader_org-browser-action"
    # "queryamoid_kaply_com-browser-action"
    # "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action"
  ];

  unified-extensions-area = [
    "ublock0_raymondhill_net-browser-action"
    "firemonkey_eros_man-browser-action"
    "addon_darkreader_org-browser-action"
    "queryamoid_kaply_com-browser-action"
    # "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action"
  ];

  extensionSettings = {
    "*" = {
      blocked_install_message = "Addon is not added in the nix config";
      installation_mode = "blocked";
    };
    "uBlock0@raymondhill.net" = {
      private_browsing = true;
      default_area = "navbar";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
    };
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
      private_browsing = true;
      default_area = "navbar";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
    };
    "vpn@proton.ch" = {
      private_browsing = true;
      default_area = "navbar";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-vpn-firefox-extension/latest.xpi";
    };
    "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack" = {
      private_browsing = true;
      default_area = "navbar";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/raindropio/latest.xpi";
    };
    "firemonkey@eros.man" = {
      private_browsing = true;
      default_area = "navbar";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/firemonkey/latest.xpi";
    };
    "addon@darkreader.org" = {
      private_browsing = true;
      # default_area = "navbar";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
    };
    "sponsorBlocker@ajay.app" = {
      private_browsing = true;
      default_area = "menupanel";
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
    };
    "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = {
      private_browsing = true;
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislikes/latest.xpi";
    };
    "frankerfacez@frankerfacez.com" = {
      private_browsing = true;
      installation_mode = "force_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/frankerfacez/latest.xpi";
    };
    # View Xpi Id's in Firefox Extension Store
    "queryamoid@kaply.com" = {
      private_browsing = true;
      installation_mode = "force_installed";
      install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.2/query_amo_addon_id-0.2-fx.xpi";
    };
  };

  extensionConfig = {
    "uBlock0@raymondhill.net" = {
      advancedSettings = [
        [
          "userResourcesLocation"
          "https://raw.githubusercontent.com/pixeltris/TwitchAdSolutions/master/video-swap-new/video-swap-new-ublock-origin.js"
        ]
      ];
      adminSettings = {
        userFilters = lib.concatMapStrings (x: x + "\n") [
          "twitch.tv##+js(twitch-videoad)"
          "||1337x.vpnonly.site"
          "||snowvan.xyz^"
        ];
        userSettings = rec {
          uiTheme = "dark";
          uiAccentCustom = true;
          uiAccentCustom0 = "#cba6f7"; # Catppuccin Mauve
          cloudStorageEnabled = lib.mkForce false;
          advancedUserEnabled = true;
          userFiltersTrusted = true;
          importedLists = [
            "https://gitflic.ru/project/magnolia1234/bypass-paywalls-clean-filters/blob/raw?file=bpc-paywall-filter.txt"
          ];
          externalLists = lib.concatStringsSep "\n" importedLists;
          popupPanelSections = 31;
        };
        selectedFilterLists = [
          "ublock-filters"
          "ublock-badware"
          "ublock-privacy"
          "ublock-quick-fixes"
          "ublock-unbreak"
          "easylist"
          "adguard-generic"
          "adguard-mobile"
          "easyprivacy"
          "adguard-spyware"
          "adguard-spyware-url"
          "fanboy-cookiemonster"
          "ublock-cookies-easylist"
          "adguard-cookies"
          "ublock-cookies-adguard"
          "fanboy-social"
          "adguard-social"
          "fanboy-thirdparty_social"
          "easylist-chat"
          "easylist-newsletters"
          "easylist-notifications"
          "easylist-annoyances"
          "adguard-mobile-app-banners"
          "adguard-other-annoyances"
          "adguard-popup-overlays"
          "adguard-widgets"
          "ublock-annoyances"
          "DEU-0"
          "FRA-0"
          "NLD-0"
          "RUS-0"
          "https://gitflic.ru/project/magnolia1234/bypass-paywalls-clean-filters/blob/raw?file=bpc-paywall-filter.txt"
          "user-filters"
        ];
      };
    };
    "addon@darkreader.org" = {
      enabled = true;
      automation = {
        enabled = true;
        behavior = "OnOff";
        mode = "system";
      };
      detectDarkTheme = true;
      enabledByDefault = true;
      changeBrowserTheme = true;
      enableForProtectedPages = true;
      fetchNews = true;
      syncSitesFixes = true;
      previewNewDesign = true;

      theme = {
        mode = 1;
        brightness = 100;
        contrast = 100;
        grayscale = 0;
        sepia = 0;
        useFont = false;
        fontFamily = "JetBrainsMono Nerd Font";
        textStroke = 0;
        engine = "staticTheme";
        stylesheet = "";
        darkSchemeBackgroundColor = "#${config.lib.stylix.colors.base00}"; # Catppuccin Mocha Background
        darkSchemeTextColor = "#${config.lib.stylix.colors.base05}"; # Catppuccin Mocha Text
        scrollbarColor = "";
        selectionColor = "#${config.lib.stylix.colors.base02}";
        styleSystemControls = true;
        lightColorScheme = "Default";
        darkColorScheme = "Default";
        immediateModify = false;
      };
    };
  };
}
