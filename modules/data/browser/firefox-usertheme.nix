{ config, ... }:
{
  userChrome = ''
    /* Native Firefox Cascade Theme Layout Rules Bridge */
    :root {
      /* Dynamic System Mappings sourced cleanly from Stylix */
      --uc-base-colour: #${config.lib.stylix.colors.base00};
      /* Absolute Black */
      --uc-highlight-colour: #${config.lib.stylix.colors.base01};
      /* Dark Material Interface Layer */
      --uc-inverted-colour: #${config.lib.stylix.colors.base05};
      /* High Contrast Text */
      --uc-muted-colour: #${config.lib.stylix.colors.base03};
      /* Subdued/Inactive Gray */
      --uc-accent-colour: #${config.lib.stylix.colors.base0E};
      /* Catppuccin Mocha Mauve Accent */

      /* Container Tabs Color Profiles */
      --uc-identity-colour-blue: #${config.lib.stylix.colors.base0D};
      --uc-identity-colour-turquoise: #${config.lib.stylix.colors.base0C};
      --uc-identity-colour-green: #${config.lib.stylix.colors.base0B};
      --uc-identity-colour-yellow: #${config.lib.stylix.colors.base0A};
      --uc-identity-colour-orange: #${config.lib.stylix.colors.base09};
      --uc-identity-colour-red: #${config.lib.stylix.colors.base08};
      --uc-identity-colour-pink: #${config.lib.stylix.colors.base0F};
      --uc-identity-colour-purple: #${config.lib.stylix.colors.base0E};
    }

    /* Cascade UI Engine Interface Bindings */
    :root {
      --lwt-frame: var(--uc-base-colour) !important;
      --lwt-accent-color: var(--lwt-frame) !important;
      --lwt-text-color: var(--uc-inverted-colour) !important;

      --toolbar-field-color: var(--uc-inverted-colour) !important;
      --toolbar-field-focus-color: var(--uc-inverted-colour) !important;
      --toolbar-field-focus-background-color: var(--uc-highlight-colour) !important;
      --toolbar-field-focus-border-color: transparent !important;
      --toolbar-field-background-color: var(--lwt-frame) !important;
      --lwt-toolbar-field-highlight: var(--uc-inverted-colour) !important;
      --lwt-toolbar-field-highlight-text: var(--uc-highlight-colour) !important;
      --urlbar-popup-url-color: var(--uc-accent-colour) !important;

      --lwt-tab-text: var(--lwt-text-color) !important;
      --lwt-selected-tab-background-color: var(--uc-highlight-colour) !important;
      --toolbar-bgcolor: var(--lwt-frame) !important;
      --toolbar-color: var(--lwt-text-color) !important;
      --toolbarseparator-color: var(--uc-accent-colour) !important;
      --toolbarbutton-hover-background: var(--uc-highlight-colour) !important;
      --toolbarbutton-active-background: var(--toolbarbutton-hover-background) !important;

      --lwt-sidebar-background-color: var(--lwt-frame) !important;
      --sidebar-background-color: var(--lwt-sidebar-background-color) !important;

      --urlbar-box-bgcolor: var(--uc-highlight-colour) !important;
      --urlbar-box-text-color: var(--uc-muted-colour) !important;
      --urlbar-box-hover-bgcolor: var(--uc-highlight-colour) !important;
      --urlbar-box-hover-text-color: var(--uc-inverted-colour) !important;
      --urlbar-box-focus-bgcolor: var(--uc-highlight-colour) !important;
    }

    /* Multi-Account Container Tab Intercept Rules */
    .identity-color-blue {
      --identity-tab-color: var(--uc-identity-colour-blue) !important;
      --identity-icon-color: var(--uc-identity-colour-blue) !important;
    }
    .identity-color-turquoise {
      --identity-tab-color: var(--uc-identity-colour-turquoise) !important;
      --identity-icon-color: var(--uc-identity-colour-turquoise) !important;
    }
    .identity-color-green {
      --identity-tab-color: var(--uc-identity-colour-green) !important;
      --identity-icon-color: var(--uc-identity-colour-green) !important;
    }
    .identity-color-yellow {
      --identity-tab-color: var(--uc-identity-colour-yellow) !important;
      --identity-icon-color: var(--uc-identity-colour-yellow) !important;
    }
    .identity-color-orange {
      --identity-tab-color: var(--uc-identity-colour-orange) !important;
      --identity-icon-color: var(--uc-identity-colour-orange) !important;
    }
    .identity-color-red {
      --identity-tab-color: var(--uc-identity-colour-red) !important;
      --identity-icon-color: var(--uc-identity-colour-red) !important;
    }
    .identity-color-pink {
      --identity-tab-color: var(--uc-identity-colour-pink) !important;
      --identity-icon-color: var(--uc-identity-colour-pink) !important;
    }
    .identity-color-purple {
      --identity-tab-color: var(--uc-identity-colour-purple) !important;
      --identity-icon-color: var(--uc-identity-colour-purple) !important;
    }
  '';

  # Stylix handles custom in-content background renderings natively.
  # We preserve the custom Newtab layout variables.
  userContent = ''
    @-moz-document url("about:newtab"), url("about:home") {
      :root {
        --newtab-background-color: #${config.lib.stylix.colors.base00} !important;
        --newtab-background-color-secondary: #${config.lib.stylix.colors.base01} !important;
        --newtab-element-hover-color: #${config.lib.stylix.colors.base01} !important;
        --newtab-text-primary-color: #${config.lib.stylix.colors.base05} !important;
        --newtab-wordmark-color: #${config.lib.stylix.colors.base05} !important;
        --newtab-primary-action-background: #${config.lib.stylix.colors.base0E} !important;
      }
      .icon { color: #${config.lib.stylix.colors.base0E} !important; }
      .card-outer:is(:hover, :focus, .active):not(.placeholder) .card-title { color: #${config.lib.stylix.colors.base0E} !important; }
      .top-site-outer .search-topsite { background-color: #${config.lib.stylix.colors.base0D} !important; }
      .compact-cards .card-outer .card-context .card-context-icon.icon-download { fill: #${config.lib.stylix.colors.base0B} !important; }
    }
  '';
}
