{ config, pkgs, lib, inputs, ... }:

let
  cliampPkg = inputs.cliamp.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = with pkgs; [
    cliampPkg
    yt-dlp # Default downloader used by gpodder-sync
  ];

  xdg.configFile."cliamp/config.toml".text = ''
    [plugins]
    # Merge with default allowlist for safe execution
    allowed_binaries = "yt-dlp"

    [plugins.gpodder-sync]
    # You can set credentials here or via 'cliamp plugins call gpodder-sync login' interactively
    # username = "your-gpodder-username"
    # password = "your-gpodder-password"
    server = "http://127.0.0.1:8081"
    auto_sync = true
    downloader = "yt-dlp"
    download_dir = "~/Music/Podcasts " # where downloaded episodes are saved
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
    if [ -x "${cliampPkg}/bin/cliamp" ]; then
      axport PATH="${cliampPkg}/bin:$PATH"
        $DRY_RUN_CMD cliamp plugins install --yes sollymay/cliamp-plugin-gpodder-sync || true
      fi
    '';
}
