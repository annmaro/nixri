{ ... }:

{
  home-manager.sharedModules = [
    ./rofi-powermenu.nix
    (
      { config, ... }: # Pass config context here
      let
        # Safe extraction of Stylix colors with structural fallbacks
        stylixColors = config.lib.stylix.colors or { };

        bgColor = "#${stylixColors.base00 or "1e1e2e"}"; # Background
        bgAltColor = "#${stylixColors.base01 or "181825"}"; # Secondary Background

        accentColor = "#${stylixColors.base0E or "cba6f7"}"; # Selected Focus
        activeColor = "#${stylixColors.base0B or "a6e3a1"}"; # Active States
        urgentColor = "#${stylixColors.base08 or "f38ba8"}"; # Alert States
        yellowColor = "#${stylixColors.base0A or "d79921"}"; # Gruvbox yellow
      in
      {
        programs.rofi = {
          enable = true;
          terminal = "kitty";
          extraConfig = import ../../../data/rofi/config.nix;

          theme =
            let
              mkLiteral = value: {
                _type = "literal";
                inherit value;
              };
            in
            {
              "*" = {
                font = "${config.stylix.fonts.monospace.name or "JetBrains Mono Nerd Font"} 10";

                background = mkLiteral bgColor;
                background-alt = mkLiteral bgAltColor;
                foreground = mkLiteral yellowColor;
                selected = mkLiteral yellowColor;
                active = mkLiteral activeColor;
                urgent = mkLiteral urgentColor;
              };

              "window" = {
                transparency = "real";
                location = mkLiteral "center";
                anchor = mkLiteral "center";
                fullscreen = false;
                width = mkLiteral "750px";
                x-offset = mkLiteral "0px";
                y-offset = mkLiteral "0px";
                enabled = true;
                border-radius = mkLiteral "20px";
                cursor = "default";
                background-color = mkLiteral "@background";
              };

              "mainbox" = {
                enabled = true;
                spacing = mkLiteral "20px";
                padding = mkLiteral "20px";
                background-color = mkLiteral "transparent";
                orientation = mkLiteral "vertical";
                children = map mkLiteral [
                  "inputbar"
                  "listview"
                ];
              };


              "inputbar" = {
                enabled = true;
                spacing = mkLiteral "10px";
                padding = mkLiteral "15px";
                background-color = mkLiteral "@background-alt";
                text-color = mkLiteral "@foreground";
                children = map mkLiteral [
                  "prompt"
                  "entry"
                ];
              };

              "prompt" = {
                enabled = true;
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "inherit";
              };

              "textbox-prompt-colon" = {
                enabled = true;
                expand = false;
                str = "";
                padding = mkLiteral "12px 15px";
                border-radius = mkLiteral "100%";
                background-color = mkLiteral "@background-alt";
                text-color = mkLiteral "inherit";
              };

              "entry" = {
                enabled = true;
                expand = false;
                width = mkLiteral "300px";
                padding = mkLiteral "12px 16px";
                border-radius = mkLiteral "100%";
                background-color = mkLiteral "@background-alt";
                text-color = mkLiteral "inherit";
                cursor = mkLiteral "text";
                placeholder = "Search";
                placeholder-color = mkLiteral "inherit";
              };

              "dummy" = {
                expand = true;
                background-color = mkLiteral "transparent";
              };

              "mode-switcher" = {
                enabled = true;
                spacing = mkLiteral "10px";
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "@foreground";
              };

              "button" = {
                width = mkLiteral "80px";
                padding = mkLiteral "12px";
                border-radius = mkLiteral "100%";
                background-color = mkLiteral "@background-alt";
                text-color = mkLiteral "inherit";
                cursor = mkLiteral "pointer";
              };

              "button selected" = {
                background-color = mkLiteral "@selected";
                text-color = mkLiteral "@foreground";
              };

              "listview" = {
                enabled = true;
                columns = 2;
                lines = 8;
                cycle = true;
                dynamic = true;
                scrollbar = false;
                layout = mkLiteral "vertical";
                reverse = false;
                fixed-height = true;
                fixed-columns = true;
                spacing = mkLiteral "10px";
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "@foreground";
                cursor = "default";
              };

              "element" = {
                enabled = true;
                spacing = mkLiteral "10px";
                padding = mkLiteral "4px";
                border-radius = mkLiteral "100%";
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "@foreground";
                cursor = mkLiteral "pointer";
              };

              "element normal.normal" = {
                background-color = mkLiteral "inherit";
                text-color = mkLiteral "inherit";
              };

              "element normal.urgent" = {
                background-color = mkLiteral "@urgent";
                text-color = mkLiteral "@foreground";
              };

              "element normal.active" = {
                background-color = mkLiteral "@active";
                text-color = mkLiteral "@foreground";
              };

              "element selected.normal" = {
                background-color = mkLiteral "@selected";
                text-color = mkLiteral "@foreground";
              };

              "element selected.urgent" = {
                background-color = mkLiteral "@urgent";
                text-color = mkLiteral "@foreground";
              };

              "element selected.active" = {
                background-color = mkLiteral "@urgent";
                text-color = mkLiteral "@foreground";
              };

              "element-icon" = {
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "inherit";
                size = mkLiteral "32px";
                cursor = mkLiteral "inherit";
              };

              "element-text" = {
                background-color = mkLiteral "transparent";
                text-color = mkLiteral "inherit";
                cursor = mkLiteral "inherit";
                vertical-align = mkLiteral "0.5";
                horizontal-align = mkLiteral "0.0";
              };

              "message" = {
                background-color = mkLiteral "transparent";
              };

              "textbox" = {
                padding = mkLiteral "12px";
                border-radius = mkLiteral "100%";
                background-color = mkLiteral "@background-alt";
                text-color = mkLiteral "@foreground";
                vertical-align = mkLiteral "0.5";
                horizontal-align = mkLiteral "0.0";
              };

              "error-message" = {
                padding = mkLiteral "12px";
                border-radius = mkLiteral "20px";
                background-color = mkLiteral "@background";
                text-color = mkLiteral "@foreground";
              };
            };
        };
      }
    )
  ];
}
