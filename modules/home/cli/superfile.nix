{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.homeSettings.tuiFileManager == "superfile";

  c = config.lib.stylix.colors;
  base00 = if c ? base00 then "#${c.base00}" else "#292828";
  base01 = if c ? base01 then "#${c.base01}" else "#32302f";
  base02 = if c ? base02 then "#${c.base02}" else "#504945";
  base03 = if c ? base03 then "#${c.base03}" else "#665c54";
  base04 = if c ? base04 then "#${c.base04}" else "#bdae93";
  base05 = if c ? base05 then "#${c.base05}" else "#ddc7a1";
  base06 = if c ? base06 then "#${c.base06}" else "#ebdbb2";
  base07 = if c ? base07 then "#${c.base07}" else "#fbf1c7";
  base08 = if c ? base08 then "#${c.base08}" else "#ea6962";
  base09 = if c ? base09 then "#${c.base09}" else "#e78a4e";
  base0A = if c ? base0A then "#${c.base0A}" else "#d8a657";
  base0B = if c ? base0B then "#${c.base0B}" else "#a9b665";
  base0C = if c ? base0C then "#${c.base0C}" else "#89b482";
  base0D = if c ? base0D then "#${c.base0D}" else "#7daea3";
  base0E = if c ? base0E then "#${c.base0E}" else "#d3869b";
  base0F = if c ? base0F then "#${c.base0F}" else "#bd6f3e";

  gruvboxMaterialTheme = ''
    ##############################################
    #                                            #
    #         Gruvbox Material Dark Theme        #
    #                                            #
    ##############################################

    code_syntax_highlight = "gruvbox"

    #-- Full Screen
    full_screen_fg = "${base05}"
    full_screen_bg = "${base00}"

    #-- Gradient
    gradient_color = ["${base0D}", "${base0A}"]

    #-- File Panel
    file_panel_fg = "${base05}"
    file_panel_bg = "${base00}"
    file_panel_border = "${base02}"
    file_panel_border_active = "${base0A}"
    file_panel_top_directory_icon = "${base0B}"
    file_panel_top_path = "${base0D}"
    file_panel_item_selected_fg = "${base0A}"
    file_panel_item_selected_bg = "${base01}"

    #-- Footer
    footer_fg = "${base05}"
    footer_bg = "${base00}"
    footer_border = "${base02}"
    footer_border_active = "${base0A}"

    #-- Sidebar
    sidebar_fg = "${base05}"
    sidebar_bg = "${base00}"
    sidebar_title = "${base08}"
    sidebar_border = "${base00}"
    sidebar_border_active = "${base0A}"
    sidebar_item_selected_fg = "${base09}"
    sidebar_item_selected_bg = "${base01}"
    sidebar_divider = "${base02}"

    #-- Modals
    modal_fg = "${base05}"
    modal_bg = "${base00}"
    modal_border_active = "${base0A}"
    modal_cancel_fg = "${base00}"
    modal_cancel_bg = "${base08}"
    modal_confirm_fg = "${base00}"
    modal_confirm_bg = "${base0B}"

    #-- Help Menu
    help_menu_hotkey = "${base0B}"
    help_menu_title = "${base0A}"

    #-- Special
    cursor = "${base0A}"
    correct = "${base0B}"
    error = "${base08}"
    hint = "${base0D}"
    cancel = "${base04}"
  '';

  superfileConfig = ''
    ##############################################
    #                                            #
    #           Superfile Configuration          #
    #                                            #
    ##############################################

    #-- File Editor
    editor = ""

    #-- Directory Editor
    dir_editor = ""

    #-- Auto check for update
    auto_check_update = false

    #-- cd on quit
    cd_on_quit = true

    #-- File Preview
    default_open_file_preview = true

    #-- Image Preview
    show_image_preview = true

    #-- File Info Footer
    show_panel_footer_info = true

    #-- Default Directory
    default_directory = "."

    #-- File Size Units
    file_size_use_si = false

    #-- Default File Sort Type
    default_sort_type = 0

    #-- Sort Order Reversing
    sort_order_reversed = false

    #-- Case-Sensitive Sorting
    case_sensitive_sort = false

    #-- Exit Shell on Success
    shell_close_on_success = false

    #-- Page Scroll Size
    page_scroll_size = 0

    #-- Debug Mode
    debug = false

    #-- Ignore Missing Config Fields
    ignore_missing_fields = true

    #-- File Panel Extra Columns Count
    file_panel_extra_columns = 0

    #-- File name width in File Panel
    file_panel_name_percent = 50

    ###############################################################################
    #                                   Styling                                   #
    ###############################################################################

    #-- Theme
    theme = "gruvbox-material"

    #-- Code Previewer
    code_previewer = ""

    #-- Nerd Fonts Support
    nerdfont = true

    #-- Show checkbox icons in select mode
    show_select_icons = true

    #-- Transparent Background Support
    transparent_background = false

    #-- File Preview Panel Width
    file_preview_width = 0

    #-- File Preview Border
    enable_file_preview_border = false

    #-- Sidebar Width
    sidebar_width = 20

    #-- Sidebar Section Order
    sidebar_sections = ["home", "pinned", "disks"]

    #-- Border
    border_top = '─'
    border_bottom = '─'
    border_left = '│'
    border_right = '│'
    border_top_left = '╭'
    border_top_right = '╮'
    border_bottom_left = '╰'
    border_bottom_right = '╯'
    border_middle_left = '├'
    border_middle_right = '┤'

    ###############################################################################
    #                                   Plugins                                   #
    ###############################################################################

    metadata = false
    enable_md5_checksum = false
    zoxide_support = false
  '';

  pinnedDirectories = [
    {
      location = config.xdg.userDirs.desktop;
      name = "Desktop";
    }
    {
      location = config.xdg.userDirs.download;
      name = "Downloads";
    }
    {
      location = config.xdg.userDirs.documents;
      name = "Documents";
    }
    {
      location = config.xdg.userDirs.pictures;
      name = "Pictures";
    }
    {
      location = config.xdg.userDirs.music;
      name = "Music";
    }
    {
      location = config.xdg.userDirs.videos;
      name = "Videos";
    }
    {
      location = config.xdg.userDirs.templates;
      name = "Templates";
    }
    {
      location = config.xdg.userDirs.publicShare;
      name = "Public";
    }
  ];

  spfBin = pkgs.writeShellScriptBin "spf" ''
    exec ${pkgs.superfile}/bin/superfile "$@"
  '';
in
lib.mkIf cfg {
  home.packages = [
    pkgs.superfile
    spfBin
  ];

  xdg.configFile."superfile/config.toml".text = superfileConfig;
  xdg.configFile."superfile/theme/gruvbox-material.toml".text = gruvboxMaterialTheme;
  xdg.dataFile."superfile/pinned.json".text = builtins.toJSON pinnedDirectories;

  programs.bash.initExtra = lib.mkIf (config.homeSettings.shell == "bash") ''
    spf() {
      local spf_last_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
      command superfile "$@"
      if [ -f "$spf_last_dir" ]; then
        . "$spf_last_dir"
        rm -f -- "$spf_last_dir" > /dev/null 2>&1
      fi
    }
  '';

  programs.zsh.initExtra = lib.mkIf (config.homeSettings.shell == "zsh") ''
    spf() {
      local spf_last_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
      command superfile "$@"
      if [ -f "$spf_last_dir" ]; then
        . "$spf_last_dir"
        rm -f -- "$spf_last_dir" > /dev/null 2>&1
      fi
    }
  '';

  programs.fish.functions = lib.mkIf (config.homeSettings.shell == "fish") {
    spf = ''
      set -l spf_last_dir "$HOME/.local/state/superfile/lastdir"
      command superfile $argv
      if test -f "$spf_last_dir"
        source "$spf_last_dir"
        rm -f -- "$spf_last_dir" > /dev/null 2>&1
      end
    '';
  };
}
