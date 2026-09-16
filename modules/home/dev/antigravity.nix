{ config, inputs, lib, pkgs, ... }:

{
  config = lib.mkIf (config.homeSettings.editor == "antigravity") {
      
      # Core Program Configuration
      # NOTE: If you experience issues signing in (e.g. browser redirect fails), 
      # please refer to the fix documented at: docs/antigravit-sign-in-fix.md
      programs.antigravity = {
        enable = true;
        
        # Inject your custom package right here!
        package = (inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-no-fhs).overrideAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [
           pkgs.curl
           pkgs.openssl
           pkgs.webkitgtk_4_1
           pkgs.libsoup_3
          ];
        });
    };

      # Custom Desktop Entry
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
      
  };
}
