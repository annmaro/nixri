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

    theme = {
      manager.border_symbol = " ";
      status = {
        separator_open = "";
        separator_close = "";
      };
    };
  };
}
