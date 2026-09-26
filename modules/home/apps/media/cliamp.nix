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

  home.activation.setupCliamp = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.config/cliamp/plugins"

    if [ -x "${patchedCliamp}/bin/cliamp" ]; then
      export PATH="${patchedCliamp}/bin:$PATH"
      $DRY_RUN_CMD cliamp plugins install --yes sollymay/cliamp-plugin-gpodder-sync || true
    fi
  '';
}
