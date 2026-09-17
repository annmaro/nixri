{ config, pkgs, inputs, ... }:

let
  wallpaperPath = "${config.users.users.${config.systemSettings.username}.home}/Pictures/Wallpapers/output_1080p.mp4";

  syscGreetPkg = inputs.sysc-greet.packages.${pkgs.system}.default;
  gSlapperPkg = inputs.gslapper.packages.${pkgs.system}.gslapper;

  greeterCommand = pkgs.writeShellScript "greetd-session" ''
    exec ${pkgs.dbus}/bin/dbus-run-session \
      ${pkgs.niri}/bin/niri --config ${syscGreetPkg}/etc/greetd/niri-greeter-config.kdl
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
