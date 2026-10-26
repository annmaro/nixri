{ config, pkgs, lib, inputs, ... }:

let
  cliampConfigTemplate = pkgs.writeText "cliamp-config-template.toml" ''
    # Your non-sensitive CLIAMP settings
    theme = "default"

    [plugins]
    allowed_private_addresses = ["172.0.0.1:8081", "127.0.0.1:8081"]

    [plugins.gpodder-sync]
    server = "http://172.0.0.1:8081"
    username = "annmaro"
    password = "@OPODSYNC_PASSWORD@"

    [sync]
    server = "http://172.0.0.1:8081"
    username = "annmaro"
    password = "@OPODSYNC_PASSWORD@"
  '';
in
{
  home.packages = with pkgs; [
    cliamp
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

    if [ -x "${pkgs.cliamp}/bin/cliamp" ]; then
      export PATH="${pkgs.cliamp}/bin:$PATH"
      $DRY_RUN_CMD cliamp plugins install --yes sollymay/cliamp-plugin-gpodder-sync || true
    fi
  '';
}
