{ config, lib, pkgs, ... }:

{
  programs.yazi = lib.mkIf (config.homeSettings.tuiFileManager == "yazi") {
    enable = true;
    enableBashIntegration = config.homeSettings.shell == "bash";
    enableZshIntegration = config.homeSettings.shell == "zsh";
    enableFishIntegration = config.homeSettings.shell == "fish";
    shellWrapperName = "y";

    plugins = {
      gvfs = pkgs.yaziPlugins.gvfs;
    };

    settings = {
      manager = {
        show_hidden = true;
        show_symlink = true;
        sort_dir_first = true;
        linemode = "size";
        ratio = [
          1
          3
          4
        ];
      };

      preview = {
        tab_size = 4;
        image_filter = "triangle";
        max_width = 1920;
        max_height = 1080;
        image_quality = 90;
      };
    };

    keymap.manager.prepend_keymap = [
      {
        on = [ "e" ];
        run = "open";
      }
      {
        on = [ "d" ];
        run = "remove --force";
      }
      {
        on = [
          "M"
          "m"
        ];
        run = "plugin gvfs -- select-then-mount --jump";
        desc = "Select device to mount and jump to its path";
      }
      {
        on = [
          "M"
          "u"
        ];
        run = "plugin gvfs -- unmount-current-cwd-device";
        desc = "Unmount current device";
      }
    ];

    # Home Manager's Yazi module supplies defaults for theme fields. Force
    # this complete theme so the Stylix values do not conflict with them.
    theme = lib.mkForce {
      manager = {
        border_symbol = " ";
        cwd = { fg = "#${config.lib.stylix.colors.base0D}"; };
        hovered = {
          fg = "#${config.lib.stylix.colors.base00}";
          bg = "#${config.lib.stylix.colors.base0A}";
        };
        preview_hovered = {
          fg = "#${config.lib.stylix.colors.base00}";
          bg = "#${config.lib.stylix.colors.base0B}";
        };
        find_keyword = {
          fg = "#${config.lib.stylix.colors.base0A}";
          italic = true;
        };
        tab_active = {
          fg = "#${config.lib.stylix.colors.base00}";
          bg = "#${config.lib.stylix.colors.base0D}";
        };
        tab_inactive = {
          fg = "#${config.lib.stylix.colors.base04}";
          bg = "#${config.lib.stylix.colors.base01}";
        };
      };
      status = {
        separator_open = "";
        separator_close = "";
        overall = {
          fg = "#${config.lib.stylix.colors.base05}";
          bg = "#${config.lib.stylix.colors.base01}";
        };
        progress_label = {
          fg = "#${config.lib.stylix.colors.base0A}";
          bold = true;
        };
        progress_normal = {
          fg = "#${config.lib.stylix.colors.base0B}";
          bg = "#${config.lib.stylix.colors.base03}";
        };
        progress_error = {
          fg = "#${config.lib.stylix.colors.base08}";
          bg = "#${config.lib.stylix.colors.base03}";
        };
      };
    };
  };
}
