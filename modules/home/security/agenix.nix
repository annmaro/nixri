{ config, inputs, pkgs, ... }:

{
  imports = [
    inputs.agenix.homeManagerModules.default
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
      private_ssh_key = {
        file = ../../../secrets/private_ssh_key.age;
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
      rclone_gdrive_env.file = ../../../secrets/rclone_gdrive_env.age;
      git_key_id.file = ../../../secrets/git_key_id.age;
      gemini_api_key.file = ../../../secrets/gemini_api_key.age;
      pihole_env = {
        file = ../../../secrets/pihole_env.age;
        path = "${config.home.homeDirectory}/.config/agenix/pihole_env";
        mode = "0600";
      };
      openrouter_api_key.file = ../../../secrets/openrouter_api_key.age;
    };
  };
}
