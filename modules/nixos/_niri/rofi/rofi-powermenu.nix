{
  config,
  pkgs,
  systemSettings,
  ...
}:

let
  wallpaperImg = "/home/${systemSettings.username}/Pictures/Wallpapers/cranerofi.jpg";

  stylixColors = config.lib.stylix.colors or { };

  bg = "#${stylixColors.base00 or "1e1e2e"}";
  bgAlt = "#${stylixColors.base01 or "181825"}";
  fg = "#${stylixColors.base05 or "cdd6f4"}";

  accent = "#${stylixColors.base0E or "cba6f7"}";
  active = "#${stylixColors.base0B or "a6e3a1"}";
  urgent = "#${stylixColors.base08 or "f38ba8"}";

  powermenuTheme = pkgs.writeText "style-2.rasi" ''
    configuration {
        show-icons:                 false;
    }

    * {
        font:                        "${
          config.stylix.fonts.monospace.name or "JetBrains Mono Nerd Font"
        } 10";
        background:                  ${bg};
        background-alt:              ${bgAlt};
        foreground:                  ${fg};
        selected:                    ${accent};
        active:                      ${active};
        urgent:                      ${urgent};
    }

    window {
        transparency:                "real";
        location:                    center;
        anchor:                      center;
        fullscreen:                  false;
        width:                       1000px;
        x-offset:                    0px;
        y-offset:                    0px;

        padding:                     0px;
        border:                      2px solid;
        border-radius:               24px;
        border-color:                @selected;
        cursor:                      "default";
        background-color:            @background;
    }

    mainbox {
        background-color:            transparent;
        orientation:                 horizontal;
        children:                    [ "imagebox", "listview" ];
    }

    imagebox {
        spacing:                     20px;
        padding:                     20px;
        background-color:            transparent;
        background-image:            url("${wallpaperImg}", height);
        children:                    [ "inputbar", "dummy", "message" ];
    }

    userimage {
        margin:                      0px 0px;
        border:                      10px;
        border-radius:               10px;
        border-color:                @background-alt;
        background-color:            transparent;
    }

    inputbar {
        padding:                     15px;
        border-radius:               100%;
        background-color:            @background-alt;
        text-color:                  @selected;
        border:                      1px solid;
        border-color:                @selected;
        children:                    [ "dummy", "prompt", "dummy"];
    }

    dummy {
        background-color:            transparent;
    }

    prompt {
        background-color:            inherit;
        text-color:                  inherit;
    }

    message {
        enabled:                     true;
        margin:                      0px;
        padding:                     15px;
        border-radius:               100%;
        background-color:            @background-alt;
        text-color:                  @foreground;
        border:                      1px solid;
        border-color:                @active;
    }
    textbox {
        background-color:            inherit;
        text-color:                  inherit;
        vertical-align:              0.5;
        horizontal-align:            0.5;
    }

    listview {
        enabled:                     true;
        columns:                     3;
        lines:                       2;
        cycle:                       true;
        dynamic:                     true;
        scrollbar:                   false;
        layout:                      vertical;
        reverse:                     false;
        fixed-height:                true;
        fixed-columns:               true;
        
        spacing:                     20px;
        margin:                      20px;
        background-color:            transparent;
        cursor:                      "default";
    }

    element {
        enabled:                     true;
        padding:                     40px 10px;
        border-radius:               100%;
        background-color:            @background-alt;
        text-color:                  @foreground;
        cursor:                      pointer;
    }
    element-text {
        font:                        "${
          config.stylix.fonts.monospace.name or "JetBrains Mono Nerd Font Bold"
        } 32";
        background-color:            transparent;
        text-color:                  inherit;
        cursor:                      inherit;
        vertical-align:              0.5;
        horizontal-align:              0.5;
    }
    element selected.normal {
        background-color:            var(selected);
        text-color:                  var(background);
    }
  '';

  powermenuScript = pkgs.writeShellScriptBin "rofi-powermenu" ''
    lock='󰌾'
    suspend='󰤄'
    logout='󰍃'
    hibernate='󰒲'
    reboot='󰜉'
    shutdown='󰐥'
    yes='󰄬'
    no='󰅖'

    raw_uptime="$(${pkgs.procps}/bin/uptime -p)"
    cleaned_uptime=''${raw_uptime#up }

    rofi_cmd() {
    	${pkgs.rofi}/bin/rofi -dmenu \
    		-p "󰀉 $USER@''$(hostname)" \
    		-mesg "󱎫 Uptime: $cleaned_uptime" \
    		-theme ${powermenuTheme}
    }

    confirm_cmd() {
    	${pkgs.rofi}/bin/rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
    		-theme-str 'mainbox {orientation: vertical; children: [ "message", "listview" ];}' \
    		-theme-str 'listview {columns: 2; lines: 1;}' \
    		-theme-str 'element-text {horizontal-align: 0.5;}' \
    		-theme-str 'textbox {horizontal-align: 0.5;}' \
    		-dmenu \
    		-p 'Confirmation' \
    		-mesg 'Are you Sure?' \
    		-theme ${powermenuTheme}
    }

    confirm_exit() {
    	echo -e "$yes\n$no" | confirm_cmd
    }

    run_rofi() {
    	echo -e "$lock\n$suspend\n$logout\n$hibernate\n$reboot\n$shutdown" | rofi_cmd
    }

    run_cmd() {
    	selected="''$(confirm_exit | ${pkgs.findutils}/bin/xargs)"
    	if [[ "$selected" == "$yes" ]]; then
    		if [[ $1 == '--shutdown' ]]; then
    			systemctl poweroff
    		elif [[ $1 == '--reboot' ]]; then
    			systemctl reboot
    		elif [[ $1 == '--hibernate' ]]; then
    			systemctl hibernate
    		elif [[ $1 == '--suspend' ]]; then
    			systemctl suspend
    		elif [[ $1 == '--logout' ]]; then
    			${pkgs.niri}/bin/niri msg action quit --skip-confirmation
    		fi
    	else
    		exit 0
    	fi
    }

    chosen="''$(run_rofi | ${pkgs.findutils}/bin/xargs)"
    case ''${chosen} in
        $shutdown)
    		run_cmd --shutdown
            ;;
        $reboot)
    		run_cmd --reboot
            ;;
        $hibernate)
    		run_cmd --hibernate
            ;;
        $lock)
            swaylock
            ;;
        $suspend)
    		run_cmd --suspend
            ;;
        $logout)
    		run_cmd --logout
            ;;
    esac
  '';
in
{
  home.packages = [ powermenuScript ];
}
