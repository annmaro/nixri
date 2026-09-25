{ inputs, ... }:

{
  home.packages = [
    inputs.bookokrat.packages.x86_64-linux.default
  ];

  xdg.configFile."bookokrat/keybindings.toml".text = ''
    [content]
    "+" = "zoom_in"
    "-" = "zoom_out"
    "=" = "reset_zoom"
  '';
}
