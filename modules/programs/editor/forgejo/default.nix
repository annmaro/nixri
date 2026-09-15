{ pkgs, config, self, ... }:

{
  # 1. Decrypt token at system level and grant read access to the runner
  age.secrets."codeberg-runner-token" = {
    file = "${self}/secrets/codeberg-runner-token.age";
    mode = "0440";
    owner = "gitea-runner";
    group = "gitea-runner";
  };

  # 2. Configure the Forgejo runner instance
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;

    instances."codeberg-runner" = {
      enable = true;
      name = "nixos-local-runner";
      url = "https://codeberg.org";

      # The decrypted file must be a systemd EnvironmentFile containing TOKEN=...
      tokenFile = config.age.secrets."codeberg-runner-token".path;

      labels = [
        "codeberg:docker://node:18-bullseye"
        "ubuntu-latest:docker://node:18-bullseye"
      ];

      settings = {
        runner = {
          capacity = 1;
          timeout = "3h";
        };
        container = {
          docker_host = "unix:///var/run/docker.sock";
          network = "bridge";
        };
      };
    };
  };

}
