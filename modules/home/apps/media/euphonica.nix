{ pkgs, ... }:

{
  home.packages = [ pkgs.euphonica ];

  xdg.configFile."euphonica/config.ron".text = ''
    (
      mpd: (
        address: "127.0.0.1:6600",
      ),
    )
  '';
}
