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
    description = "Install the QtGreet video wallpaper (re-encoded for MPV)";
    wantedBy = [ "greetd.service" ];
    before = [ "greetd.service" ];
    unitConfig.ConditionPathExists = wallpaperPath;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Re-encode for MPV compatibility: H.264 baseline, yuv420p, no audio, faststart
      ${pkgs.ffmpeg}/bin/ffmpeg -y -i ${wallpaperPath} \
        -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p \
        -an -movflags +faststart \
        /etc/greetd/wallpaper.mp4
      # Also copy to user's wallpaper directory for desktop session
      ${pkgs.coreutils}/bin/install -Dm0644 \
        /etc/greetd/wallpaper.mp4 \
        ${config.users.users.${config.systemSettings.username}.home}/Pictures/Wallpapers/output.mp4
      # Create M3U playlist with loop directive (MPV respects --loop-playlist)
      printf '#EXTM3U\n#EXTINF:-1,loop\n/etc/greetd/wallpaper.mp4\n' \
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
    ffmpeg
  ];
}
