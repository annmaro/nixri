{ config, pkgs, ... }:

let
  wallpaper = "${config.users.users.${config.systemSettings.username}.home}/Pictures/Wallpapers/output_1080p.mp4";
  qtgreetTheme = "qtgreet/themes/nixri-video";
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
      ${pkgs.sway}/bin/sway --config ${greeterSwayConfig}
  '';
in
{
  environment.etc."greetd/wallpaper.mp4".source = wallpaper;

  environment.etc."qtgreet/config.ini".text = ''
    [General]
    Backend = GreetD
    Theme = nixri-video
    BlurBackground = false
    IconTheme = breeze

    [Overrides]
    Background = Theme
    BaseColor = Theme
    TextColor = Theme
    FontFamily = Theme

    [Environment]

    [PowerCommands]
    Suspend = dbus
    Hibernate = dbus
    Shutdown = dbus
    Reboot = dbus
  '';

  environment.etc."${qtgreetTheme}/index.theme".text = ''
    [General]
    Name = Nixri Video

    [Files]
    Layout = layout.hjson
    StyleSheet = style.qss

    [Theme]
    BaseColor = ffffffff
    TextColor = ffffffff
    Type = Video

    [videobg]
    File = /etc/greetd/wallpaper.mp4
  '';

  environment.etc."${qtgreetTheme}/layout.hjson".source =
    "${pkgs.qtgreet}/share/qtgreet/themes/default/layout.hjson";
  environment.etc."${qtgreetTheme}/style.qss".source =
    "${pkgs.qtgreet}/share/qtgreet/themes/default/style.qss";

  environment.variables.QTGREET_THEME_DIRS = "/etc/qtgreet/themes";

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
