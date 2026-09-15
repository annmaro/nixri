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
          "codeberg-runner-token" = {
            file = "${self}/secrets/codeberg-runner-token.age";
            path = "${config.home.homeDirectory}/.config/forgejo-runner/token";
          };
          "git_key_id" = {
            file = "${self}/secrets/git_key_id.age";
          };
          "gemini_api_key" = {
            file = "${self}/secrets/gemini_api_key.age";
          };
        };
      };
    };
}
