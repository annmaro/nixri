{ config, pkgs, inputs, ... }:

let
  wallpaperPath = "${config.users.users.${config.systemSettings.username}.home}/Pictures/Wallpapers/output_1080p.mp4";

  syscGreetPkg = inputs.sysc-greet.packages.${pkgs.system}.default;
  gSlapperPkg = inputs.gslapper.packages.${pkgs.system}.gslapper;

  niriGreeterConfig = pkgs.writeText "niri-greeter.kdl" ''
    hotkey-overlay {
        skip-at-startup
    }

    input {
        keyboard {
            xkb {
                layout "us"
            }
            repeat-delay 400
            repeat-rate 40
        }
        touchpad {
            tap
        }
    }

    // Correctly split arguments to avoid kitty execution errors
    spawn-at-startup "${pkgs.kitty}/bin/kitty" "--config" "${syscGreetPkg}/etc/greetd/kitty.conf" "${syscGreetPkg}/bin/sysc-greet" "--cmd" "niri-session"

    layout {
        focus-ring {
            off
        }
        border {
            off
        }
    }

    window-rule {
        match app-id="kitty"
        default-column-width {}
    }
    
    window-rule {
        match app-id="kitty"
        open-fullscreen true
    }
  '';

  greeterCommand = pkgs.writeShellScript "greetd-session" ''
    exec ${pkgs.dbus}/bin/dbus-run-session ${pkgs.niri}/bin/niri --config ${niriGreeterConfig}
  '';
in
{
  systemd.services.greetd-wallpaper = {
    description = "Install the gSlapper video wallpaper";
    wantedBy = [ "greetd.service" ];
    before = [ "greetd.service" ];
    unitConfig.ConditionPathExists = wallpaperPath;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /etc/greetd
      # Copy to /etc/greetd/wallpaper.mp4 for gslapper
      ${pkgs.coreutils}/bin/install -Dm0644 \
        ${wallpaperPath} \
        /etc/greetd/wallpaper.mp4
      # Also copy to user's wallpaper directory for desktop session
      ${pkgs.coreutils}/bin/install -Dm0644 \
        /etc/greetd/wallpaper.mp4 \
        ${config.users.users.${config.systemSettings.username}.home}/Pictures/Wallpapers/output.mp4
    '';
  };

  systemd.services.greetd = {
    requires = [ "greetd-wallpaper.service" ];
    after = [ "greetd-wallpaper.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/greetd 0755 greeter greeter - -"
    "d /var/lib/greetd/.cache 0755 greeter greeter - -"
    "d /var/lib/greetd/.cache/sysc-greet 0755 greeter greeter - -"
    "f /var/lib/greetd/.cache/sysc-greet/session 0644 greeter greeter - {\"Name\":\"niri\",\"Exec\":\"niri-session\",\"Type\":\"Wayland\"}"
    "f /var/lib/greetd/.cache/sysc-greet/preferences 0644 greeter greeter - {\"Username\":\"${config.systemSettings.username}\"}"
  ];

  services.displayManager.defaultSession = "niri";

  services.greetd = {
    enable = true;
    restart = true;
    settings.default_session = {
      command = greeterCommand;
      user = "greeter";
    };
  };

  environment.systemPackages = with pkgs; [
    syscGreetPkg
    gSlapperPkg
  ];
}
