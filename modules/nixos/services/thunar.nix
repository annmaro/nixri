{ pkgs, ... }:

{
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
    ];
  };

  environment.systemPackages = [ pkgs.file-roller ];
}
