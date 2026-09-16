{
  config,
  pkgs,
  ...
}:

let
  stylixColors = config.lib.stylix.colors or { };

  bg = "#${stylixColors.base00 or "282828"}";
  bgAlt = "#${stylixColors.base01 or "3c3836"}";
  yellow = "#${stylixColors.base0A or "d79921"}";

  powermenuTheme = pkgs.writeText "style-1.rasi" ''
    configuration {
        show-icons:                 false;
    }

    * {
        mainbox-spacing:            100px;
        mainbox-margin:             100px 300px;
        message-margin:             0px 400px;
        message-padding:            15px;
        message-border-radius:      100%;
        listview-spacing:           50px;
        element-padding:            55px 60px;
        element-border-radius:      100%;

        prompt-font:                "${config.stylix.fonts.monospace.name or "JetBrains Mono Nerd Font Bold Italic"} 64";
        textbox-font:               "${config.stylix.fonts.monospace.name or "JetBrains Mono Nerd Font"} 16";
        element-text-font:          "${config.stylix.fonts.monospace.name or "JetBrains Mono Nerd Font"} 64";

        background-window:          ${bg};
        background-normal:          ${bgAlt};
        background-selected:        ${bgAlt};
        foreground-normal:          ${yellow};
        foreground-selected:        ${yellow};
    }

    window {
        transparency:               "real";
        location:                   center;
        anchor:                     center;
        fullscreen:                 true;
        cursor:                      "default";
        background-color:           var(background-window);
    }

    mainbox {
        enabled:                    true;
        spacing:                    var(mainbox-spacing);
        margin:                     var(mainbox-margin);
        background-color:           transparent;
        children:                   [ "dummy", "inputbar", "listview", "message", "dummy" ];
    }

    dummy {
        background-color:           transparent;
    }

    inputbar {
        enabled:                    true;
        background-color:           transparent;
        children:                   [ "dummy", "prompt", "dummy" ];
    }

    prompt {
        enabled:                    true;
        font:                       var(prompt-font);
        background-color:           transparent;
        text-color:                 var(foreground-normal);
    }

    message {
        enabled:                    true;
        margin:                     var(message-margin);
        padding:                    var(message-padding);
        border-radius:              var(message-border-radius);
        background-color:           var(background-normal);
        text-color:                 var(foreground-normal);
    }

    textbox {
        font:                       var(textbox-font);
        background-color:           transparent;
        text-color:                 var(foreground-normal);
        vertical-align:             0.5;
        horizontal-align:           0.5;
    }

    listview {
        enabled:                    true;
        expand:                     false;
        columns:                    5;
        lines:                      1;
        cycle:                      true;
        dynamic:                    true;
        scrollbar:                  false;
        layout:                     vertical;
        reverse:                    false;
        fixed-height:               true;
        fixed-columns:              true;
        spacing:                    var(listview-spacing);
        background-color:           transparent;
        cursor:                     "default";
    }

    element {
        enabled:                    true;
        padding:                    var(element-padding);
        border-radius:              var(element-border-radius);
        background-color:           var(background-normal);
        text-color:                 var(foreground-normal);
        cursor:                     pointer;
    }

    element-text {
        font:                       var(element-text-font);
        background-color:           transparent;
        text-color:                 var(foreground-normal);
        cursor:                     inherit;
        vertical-align:             0.5;
        horizontal-align:           0.5;
    }

    element selected.normal {
        background-color:           var(background-selected);
        text-color:                 var(foreground-selected);
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
