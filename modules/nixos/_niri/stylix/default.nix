{
  pkgs,
  inputs,
  ...
}:

{
  # 1. System-level environment variables (keep this at the root module level)
  environment.variables = {
    XCURSOR_THEME = "catppuccin-mocha-mauve-cursors";
    XCURSOR_SIZE = "24";
  };

  home-manager.sharedModules = [
    (
      { config, ... }:
      {
        imports = [
          inputs.stylix.homeModules.stylix
          inputs.niri.homeModules.stylix
        ];

        stylix = {
          enable = true;
          polarity = "dark";
          enableReleaseChecks = false;

          base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";

          # 2. Let Stylix handle your Bibata cursor globally
          cursor = {
            package = pkgs.catppuccin-cursors.mochaMauve;
            name = "catppuccin-mocha-mauve-cursors";
            size = 24;
          };

          targets = {
            niri.enable = true;
            gtk = {
              enable = true;
              extraCss = ''
                window.csd > decoration {
                  border: 1px solid #${config.lib.stylix.colors.base0D};
                  outline: none;
                  box-shadow: none;
                }
                decoration {
                  border: 1px solid #${config.lib.stylix.colors.base0D};
                  outline: none;
                  box-shadow: none;
                }

                /* Override Thunar Menu Popups for readability */
                window.thunar menu, window.thunar .menu, window.thunar popover {
                  background-color: #${config.lib.stylix.colors.base01};
                  color: #${config.lib.stylix.colors.base05};
                  border: 1px solid #${config.lib.stylix.colors.base0E};
                }
                window.thunar menuitem:hover, window.thunar .menuitem:hover {
                  background-color: #${config.lib.stylix.colors.base0A};
                  color: #${config.lib.stylix.colors.base00};
                }
              '';
            };
            qt.enable = true;
            btop.enable = true;
            foot.enable = true;
            swaylock.enable = true; # Tells Stylix to inject the colors into the locker lock ring
            firefox = {
              enable = true; # Ensures Stylix automatically hooks into the layout template
              profileNames = [ "default" ]; # Instructs Stylix which specific active profiles to look up
            };

            # --- DISABLE STYLIX FOR THESE SPECIFIC APPS ---
            kitty.enable = false; # Disabled because Stylix dims terminal colors unexpectedly
            zed.enable = false;
            waybar.enable = false; # We want to manage Waybar's theme manually to leverage its native styling capabilities
            dank-material-shell.enable = false;

            # Add any other apps here if you want to manage their themes manually:
            spicetify.enable = false;
            cava.enable = false;
            feh.enable = false;
            neovim.enable = false;
            yazi.enable = false;
          };

          # Generate a 1x1 solid black pixel on the fly as your wallpaper engine source
          /*
            image = pkgs.runCommand "amoled_black.png" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
              convert -size 1x1 xc:#000000 $out
            '';
          */

          icons = {
            enable = true;
            package = pkgs.papirus-icon-theme.override { color = "yellow"; };
            dark = "Papirus-Dark";
            light = "Papirus-Light";
          };

          fonts = {
            monospace = {
              package = pkgs.nerd-fonts.jetbrains-mono;
              name = "JetBrainsMono Nerd Font";
            };
            sansSerif = {
              package = pkgs.dejavu_fonts;
              name = "DejaVu Sans";
            };
          };
        };
      }
    )
  ];
}
