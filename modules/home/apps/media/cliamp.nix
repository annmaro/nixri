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
    # You can set credentials here or via 'cliamp plugins gpodder-sync login' interactively
    # username = "your-gpodder-username"
    # password = "your-gpodder-password"
    auto_sync = true
    downloader = "yt-dlp"
    download_dir       = "~/Music/Podcasts " # where downloaded episodes are saved
  '';

  # Automatically install and trust the plugin on home-manager switch
  home.activation.installCliampGpodderSync = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.config/cliamp/plugins"

    # Install and trust the plugin non-interactively
    if [ -x "${cliampPkg}/bin/cliamp" ]; then
      export PATH="${cliampPkg}/bin:$PATH"
      $DRY_RUN_CMD cliamp plugins install --yes sollymay/cliamp-plugin-gpodder-sync || true
    fi
  '';
}
