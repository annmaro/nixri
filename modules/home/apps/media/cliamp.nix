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

  cliampConfigTemplate = pkgs.writeText "cliamp-config-template.toml" ''
    # Your non-sensitive CLIAMP settings
    theme = "default"

    [sync]
    server = "http://172.0.0.1:8081"
    username = "annmaro"
    password = "@OPODSYNC_PASSWORD@"
  '';
in
{
  home.packages = with pkgs; [
    patchedCliamp
    yt-dlp
  ];

  home.activation.setupCliamp = lib.hm.dag.entryAfter ["writeBoundary"] ''
    CONFIG_DIR="${config.home.homeDirectory}/.config/cliamp"
    SECRET_PATH="${config.age.secrets.opodsyncPassword.path}"

    $DRY_RUN_CMD mkdir -p "$CONFIG_DIR/plugins"

    if [ -f "$SECRET_PATH" ]; then
      PASSWORD=$($DRY_RUN_CMD cat "$SECRET_PATH")
      $DRY_RUN_CMD sed "s|@OPODSYNC_PASSWORD@|$PASSWORD|g" "${cliampConfigTemplate}" > "$CONFIG_DIR/config.toml"
      $DRY_RUN_CMD chmod 600 "$CONFIG_DIR/config.toml"
    fi

    if [ -x "${patchedCliamp}/bin/cliamp" ]; then
      export PATH="${patchedCliamp}/bin:$PATH"
      $DRY_RUN_CMD cliamp plugins install --yes sollymay/cliamp-plugin-gpodder-sync || true
    fi
  '';
}
