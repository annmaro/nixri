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
        inputs.agenix.homeManagerModules.age
        ./git.nix
      ];

      home.packages = [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      age = {
        identityPaths = [ "${config.home.homeDirectory}/.config/agenix/key.txt" ];

        secrets = {
          "private_ssh_key" = {
            file = ../../../secrets/private_ssh_key.age;
            path = "${config.home.homeDirectory}/.ssh/id_ed25519";
            mode = "0600";
          };
          "rclone_gdrive_env" = {
            file = ../../../secrets/rclone_gdrive_env.age;
          };

          "git_key_id" = {
            file = ../../../secrets/git_key_id.age;
          };
          "gemini_api_key" = {
            file = ../../../secrets/gemini_api_key.age;
          };
        };
      };
    };
}
