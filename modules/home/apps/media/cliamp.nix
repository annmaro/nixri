{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    cliamp
    yt-dlp # Default downloader used by gpodder-sync
  ];

  xdg.configFile."cliamp/config.toml".text = ''
    [plugins]
    # Merge with default allowlist for safe execution
    allowed_binaries = "yt-dlp"

    [plugins.gpodder-sync]
    # You can set credentials here or via 'cliamp plugins gpodder-sync login' interactively
    # username = "your-gpodder-username"
    # password = "your-gpodder-password"
    auto_sync = true
    downloader = "yt-dlp"
  '';

  # Automatically install and trust the plugin on home-manager switch
  home.activation.installCliampGpodderSync = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.config/cliamp/plugins"

    # Install and trust the plugin non-interactively
    if [ -x "${pkgs.cliamp}/bin/cliamp" ]; then
      export PATH="${pkgs.cliamp}/bin:$PATH"
      $DRY_RUN_CMD cliamp plugins install --yes sollymay/cliamp-plugin-gpodder-sync || true
    fi
  '';
}
