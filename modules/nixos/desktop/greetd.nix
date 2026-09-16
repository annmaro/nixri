{ config, pkgs, ... }:

let
  wallpaper = "${config.users.users.${config.systemSettings.username}.home}/Pictures/Wallpapers/output.mp4";
  greeterSwayConfig = pkgs.writeText "greetd-sway.conf" ''
    default_border none
    default_floating_border none
    output * bg #000000 solid_color
    exec ${pkgs.mpvpaper}/bin/mpvpaper -o "no-audio --loop-file=inf --cache=no --demuxer-readahead-secs=1 --hwdec=auto" '*' '${wallpaper}'
    exec ${pkgs.regreet}/bin/regreet
  '';
  greeterCommand = pkgs.writeShellScript "greetd-session" ''
    exec ${pkgs.sway}/bin/sway --config ${greeterSwayConfig}
  '';
in
{
  services.displayManager.defaultSession = "niri";

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
