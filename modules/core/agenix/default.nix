{
  self,
  host,
  config,
  inputs,
  pkgs,
  ...
}:
let
  inherit (import "${self}/hosts/${host}/variables.nix") username;
in
{
  home-manager.users.${username} =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.agenix.homeManagerModules.default
        ./git.nix
      ];

      home.packages = [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      home.sessionVariablesExtra = ''
        if [ -f "${config.age.secrets.gemini_api_key.path}" ]; then
          export GEMINI_API_KEY="$(cat "${config.age.secrets.gemini_api_key.path}")"
        fi
        if [ -f "${config.age.secrets.openrouter_api_key.path}" ]; then
          export OPENROUTER_API_KEY="$(cat "${config.age.secrets.openrouter_api_key.path}")"
        fi
      '';

      age = {
        identityPaths = [ "${config.home.homeDirectory}/.config/agenix/key.txt" ];

        secrets = {
          "private_ssh_key" = {
            file = "${self}/secrets/private_ssh_key.age";
            path = "${config.home.homeDirectory}/.ssh/id_ed25519";
            mode = "0600";
          };
          "rclone_gdrive_env" = {
            file = "${self}/secrets/rclone_gdrive_env.age";
          };
          "git_key_id" = {
            file = "${self}/secrets/git_key_id.age";
          };
          "gemini_api_key" = {
            file = "${self}/secrets/gemini_api_key.age";
          };
          "openrouter_api_key" = {
            file = "${self}/secrets/openrouter_api_key.age";
          };
        };
      };
    };
}
