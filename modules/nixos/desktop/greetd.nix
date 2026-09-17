{ config, pkgs, ... }:

let
  wallpaper = "${config.users.users.${config.systemSettings.username}.home}/Pictures/Wallpapers/output_1080p.mp4";
  greeterWallpaper = "/etc/greetd/wallpaper.mp4";
  greeterSwayConfig = pkgs.writeText "greetd-sway.conf" ''
    default_border none
    default_floating_border none
    output * bg #000000 solid_color
    exec ${pkgs.mpvpaper}/bin/mpvpaper -o "no-audio --loop-file=inf --cache=no --demuxer-readahead-secs=1 --hwdec=auto" '*' '${greeterWallpaper}'
    exec ${pkgs.regreet}/bin/regreet
  '';
  greeterCommand = pkgs.writeShellScript "greetd-session" ''
    exec ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --config ${greeterSwayConfig}
  '';
in
{
  environment.etc."greetd/wallpaper.mp4".source = wallpaper;

  services.displayManager.defaultSession = "niri";
  services.displayManager.regreet = {
    enable = true;
    settings.skip_selection = true;
    extraCss = ''
      /* The centered frame is the login panel; the clock frame also has
         the background class but is marked as a top overlay. */
      overlay > frame.background:not(.top) {
        margin-left: 40px;
        margin-right: 540px;
      }
    '';
  };

  services.greetd = {
    enable = true;
    restart = true;
    settings.default_session = {
      command = greeterCommand;
      user = "greeter";
    };
  };

  environment.systemPackages = with pkgs; [
    mpvpaper
    regreet
    sway
  ];
}
