{ config, pkgs, ... }:

let
  wallpaperPath = "${config.users.users.${config.systemSettings.username}.home}/Pictures/Wallpapers/output_1080p.mp4";

  sessionDesktops = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  greeterSwayConfig = pkgs.writeText "qtgreet-sway.conf" ''
    default_border none
    default_floating_border none
    exec ${pkgs.qtgreet}/bin/qtgreet \
      --config /etc/qtgreet/config.ini \
      --data-path /var/lib/qtgreet \
      --wl-session-path ${sessionDesktops}
  '';
  greeterCommand = pkgs.writeShellScript "greetd-session" ''
    exec ${pkgs.dbus}/bin/dbus-run-session \
      env QTGREET_THEME_DIRS=${pkgs.qtgreet}/share/qtgreet/themes \
      ${pkgs.sway}/bin/sway --config ${greeterSwayConfig}
  '';
in
{
  systemd.services.greetd-wallpaper = {
    description = "Install the QtGreet video wallpaper and playlist";
    wantedBy = [ "greetd.service" ];
    before = [ "greetd.service" ];
    unitConfig.ConditionPathExists = wallpaperPath;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.coreutils}/bin/install -Dm0644 \
        ${wallpaperPath} /etc/greetd/wallpaper.mp4
      # Create an M3U playlist that loops the video infinitely
      printf '#EXTM3U\n#EXT-X-REPEAT\n/etc/greetd/wallpaper.mp4\n' \
        > /etc/greetd/wallpaper.m3u
    '';
  };

  systemd.services.greetd = {
    requires = [ "greetd-wallpaper.service" ];
    after = [ "greetd-wallpaper.service" ];
  };

  environment.etc."qtgreet/config.ini".text = ''
    [General]
    Backend = GreetD
    Theme = aerial
    BlurBackground = false
    IconTheme = breeze

    [Overrides]
    Background = Theme
    BaseColor = Theme
    TextColor = Theme
    FontFamily = Theme

    [videobg]
    Playlist = /etc/greetd/wallpaper.m3u

    [Environment]

    [PowerCommands]
    Suspend = dbus
    Hibernate = dbus
    Shutdown = dbus
    Reboot = dbus
  '';


  systemd.tmpfiles.rules = [
    "d /var/lib/qtgreet 0755 greeter greeter - -"
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
    qtgreet
    sway
  ];
}
