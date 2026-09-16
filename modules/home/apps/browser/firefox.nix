{ config, inputs, lib, pkgs, ... }:

let
  theme = import ../../../data/browser/firefox-usertheme.nix { inherit config; };
in
{
  programs.firefox = lib.mkIf (config.homeSettings.browser == "firefox") {
    enable = true;
    languagePacks = [
      "en-GB"
      "en-US"
    ];

    policies = import ../../../data/browser/firefox-policies.nix {
      inherit config lib;
    };

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = import ../../../data/browser/firefox-settings.nix {
              inherit config lib;
            };
      bookmarks = import ../../../data/browser/bookmarks.nix;
      search = import ../../../data/browser/firefox-search.nix { inherit pkgs; };
      userChrome = theme.userChrome;
      userContent = theme.userContent;

      extraConfig = ''
        ${builtins.readFile "${inputs.betterfox}/Fastfox.js"}
        ${builtins.readFile "${inputs.betterfox}/Peskyfox.js"}
        ${builtins.readFile "${inputs.betterfox}/Securefox.js"}
        ${builtins.readFile "${inputs.betterfox}/Smoothfox.js"}

        lockPref("extensions.formautofill.addresses.enabled", false);
        lockPref("extensions.formautofill.creditCards.enabled", false);
        lockPref("dom.security.https_only_mode_pbm", true);
        lockPref("dom.security.https_only_mode_error_page_user_suggestions", true);
        lockPref("browser.firefox-view.feature-tour", "{\"screen\":\"\",\"complete\":true}");
        lockPref("identity.fxaccounts.enabled", false);
        lockPref("browser.tabs.firefox-view-next", false);
        lockPref("privacy.sanitize.sanitizeOnShutdown", false);
        lockPref("privacy.clearOnShutdown.cache", true);
        lockPref("privacy.clearOnShutdown.cookies", false);
        lockPref("privacy.clearOnShutdown.offlineApps", false);
        lockPref("browser.sessionstore.privacy_level", 0);
        lockPref("floorp.browser.sidebar.enable", false);
        lockPref("geo.enabled", false);
        lockPref("media.navigator.enabled", false);
        lockPref("dom.event.clipboardevents.enabled", false);
        lockPref("dom.event.contextmenu.enabled", false);
        lockPref("dom.battery.enabled", false);
        lockPref("extensions.enabledScopes", 15);
        lockPref("extensions.autoDisableScopes", 0);
        lockPref("browser.newtabpage.activity-stream.floorp.newtab.imagecredit.hide", true);
        lockPref("browser.newtabpage.activity-stream.floorp.newtab.releasenote.hide", true);
        lockPref("browser.search.separatePrivateDefault", true);
      '';
    };
  };
}
