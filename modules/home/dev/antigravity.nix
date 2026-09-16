{ config, inputs, lib, pkgs, ... }:

let
  antigravityPackage =
    (inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-no-fhs).overrideAttrs
      (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [
          pkgs.curl
          pkgs.openssl
          pkgs.webkitgtk_4_1
          pkgs.libsoup_3
        ];
      });
in
{
  config = lib.mkMerge [
    # Keep Antigravity installed as an alternate editor.
    { home.packages = [ antigravityPackage ]; }
    (lib.mkIf (config.homeSettings.editor == "antigravity") {
      programs.antigravity = {
        enable = true;
        package = antigravityPackage;
      };

      home.file.".local/share/applications/antigravity.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Exec=antigravity %F
        Icon=antigravity
        Name=Antigravity
        Comment=Antigravity - Google AI-powered Code Editor
        Categories=Development;IDE;
        Terminal=false
        MimeType=text/plain;
      '';
    })
  ];
}
