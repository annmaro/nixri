{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    cliamp
    yt-dlp # Default downloader used by gpodder-sync
  ];

  xdg.configFile."cliamp/config.base.toml".text = ''
    [plugins]
    # Merge with default allowlist for safe execution
    allowed_binaries = "yt-dlp"

    [plugins.gpodder-sync]
    server = "http://127.0.0.1:8081"
    auto_sync = true
    downloader = "yt-dlp"
    download_dir = "~/Music/Podcasts"
  '';

  # Combined activation script: installs plugin & merges secret credentials
  home.activation.setupCliamp = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.config/cliamp/plugins"

    # Assemble config.toml from the declarative base and the local secret file
    TARGET="$HOME/.config/cliamp/config.toml"
    rm -f "$TARGET"
    cat "$HOME/.config/cliamp/config.base.toml" > "$TARGET"

    if [ -f "$HOME/.config/cliamp/secrets.toml" ]; then
      cat "$HOME/.config/cliamp/secrets.toml" >> "$TARGET"
    fi
    chmod 600 "$TARGET"

    # Install the plugin non-interactively
    if [ -x "${pkgs.cliamp}/bin/cliamp" ]; then
      export PATH="${pkgs.cliamp}/bin:$PATH"
      $DRY_RUN_CMD cliamp plugins install --yes sollymay/cliamp-plugin-gpodder-sync || true
    fi
  '';
}
