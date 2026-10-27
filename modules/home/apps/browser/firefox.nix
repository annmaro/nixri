{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:

let
  theme = import "${self}/modules/data/browser/firefox-usertheme.nix" { inherit config; };
in
{
  # Keep Firefox available even when another browser is the default.
  home.packages = lib.optional (config.homeSettings.browser != "firefox") pkgs.firefox;

  programs.firefox = lib.mkIf (config.homeSettings.browser == "firefox") {
    enable = true;
    nativeMessagingHosts = [ pkgs.keepassxc ];
    languagePacks = [
      "en-GB"
      "en-US"
    ];

    policies = import "${self}/modules/data/browser/firefox-policies.nix" {
      inherit config lib;
    };

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = import "${self}/modules/data/browser/firefox-settings.nix" {
        inherit config lib;
      };
      bookmarks = import "${self}/modules/data/browser/bookmarks.nix";
      search = import "${self}/modules/data/browser/firefox-search.nix" { inherit pkgs; };
      userChrome = theme.userChrome;
      userContent = theme.userContent;

      extraConfig = ''
        ${builtins.readFile "${inputs.betterfox}/Fastfox.js"}
        ${builtins.readFile "${inputs.betterfox}/Peskyfox.js"}
        ${builtins.readFile "${inputs.betterfox}/Securefox.js"}
        ${builtins.readFile "${inputs.betterfox}/Smoothfox.js"}

        user_pref("extensions.formautofill.addresses.enabled", false);
        user_pref("extensions.formautofill.creditCards.enabled", false);
        user_pref("dom.security.https_only_mode_pbm", true);
        user_pref("dom.security.https_only_mode_error_page_user_suggestions", true);
        user_pref("browser.firefox-view.feature-tour", "{\"screen\":\"\",\"complete\":true}");
        user_pref("identity.fxaccounts.enabled", false);
        user_pref("privacy.sanitize.sanitizeOnShutdown", false);
        user_pref("privacy.clearOnShutdown.cache", true);
        user_pref("privacy.clearOnShutdown.cookies", false);
        user_pref("privacy.clearOnShutdown.offlineApps", false);
        user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);
        user_pref("browser.sessionstore.privacy_level", 0);
        user_pref("geo.enabled", false);
        user_pref("media.navigator.enabled", false);
        user_pref("dom.event.clipboardevents.enabled", false);
        user_pref("dom.event.contextmenu.enabled", false);
        user_pref("dom.battery.enabled", false);
        user_pref("extensions.enabledScopes", 15);
        user_pref("extensions.autoDisableScopes", 0);
        user_pref("browser.search.separatePrivateDefault", true);
      '';
    };
  };
}
