{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      maple-mono.NF
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "Maple Mono NF" "Noto Mono" "DejaVu Sans Mono" ];
        sansSerif = [ "Noto Sans" "DejaVu Sans" ];
        serif = [ "Noto Serif" "DejaVu Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
