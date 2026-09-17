{ config, pkgs, ... }:

let
  wallpaper = "${config.users.users.${config.systemSettings.username}.home}/Pictures/Wallpapers/output_1080p.mp4";
  greeterSwayConfig = pkgs.writeText "greetd-sway.conf" ''
    default_border none
    default_floating_border none
    output * bg #000000 solid_color
    exec ${pkgs.mpvpaper}/bin/mpvpaper -o "no-audio --loop-file=inf --cache=no --demuxer-readahead-secs=1 --hwdec=auto" '*' '${wallpaper}'
    exec ${pkgs.regreet}/bin/regreet
  '';
  greeterCommand = pkgs.writeShellScript "greetd-session" ''
    exec ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --config ${greeterSwayConfig}
  '';
in
{
  services.displayManager.defaultSession = "niri";
  services.displayManager.regreet = {
    enable = true;
    settings.skip_selection = true;
    extraCss = ''
      /* ReGreet's main login frame is the second child of the overlay,
         after the background picture. */
      overlay > frame.background:nth-child(2) {
        margin-left: 8%;
        margin-right: 58%;
      }
    '';
  };

  services.greetd = {
    enable = true;
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
