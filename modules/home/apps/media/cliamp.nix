{ config, pkgs, lib, inputs, ... }:

let
  patchedCliamp = (inputs.cliamp.packages.${pkgs.stdenv.hostPlatform.system}.default).overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      (pkgs.writeText "cliamp-allow-local.patch" ''
--- a/luaplugin/api_http.go
+++ b/luaplugin/api_http.go
@@ -26,10 +26,6 @@
 	if ip == nil {
 		return fmt.Errorf("cannot resolve dial address %q", address)
 	}
-	if ip.IsLoopback() || ip.IsPrivate() || ip.IsLinkLocalUnicast() ||
-		ip.IsLinkLocalMulticast() || ip.IsMulticast() || ip.IsUnspecified() {
-		return fmt.Errorf("blocked request to non-public address %s", ip)
-	}
 	return nil
 }
      '')
    ];
  });
in
{
  home.packages = with pkgs; [
    patchedCliamp
    yt-dlp
  ];

  xdg.configFile."cliamp/config.base.toml".text = ''
    [plugins]
    allowed_binaries = "yt-dlp"

    [plugins.gpodder-sync]
    server = "http://127.0.0.1:8081"
    auto_sync = true
    downloader = "yt-dlp"
    download_dir = "~/Music/Podcasts"
  '';

  home.activation.setupCliamp = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.config/cliamp/plugins"

    TARGET="$HOME/.config/cliamp/config.toml"
    rm -f "$TARGET"
    cat "$HOME/.config/cliamp/config.base.toml" > "$TARGET"

    if [ -f "$HOME/.config/cliamp/secrets.toml" ]; then
      grep -v '\[plugins.gpodder-sync\]' "$HOME/.config/cliamp/secrets.toml" >> "$TARGET"
    fi
    chmod 600 "$TARGET"

    if [ -x "${patchedCliamp}/bin/cliamp" ]; then
      export PATH="${patchedCliamp}/bin:$PATH"
      $DRY_RUN_CMD cliamp plugins install --yes sollymay/cliamp-plugin-gpodder-sync || true
    fi
  '';
}
