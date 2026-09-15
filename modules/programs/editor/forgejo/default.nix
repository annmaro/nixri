{ pkgs, self, ... }:

{
  # Configure the Forgejo runner instance
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;

    instances."codeberg-runner" = {
      enable = true;
      name = "nixos-local-runner";
      url = "https://codeberg.org";

      # File holding only the plain registration token from Codeberg
      tokenFile = "/home/annmaro/.config/forgejo-runner/token";

      # Map the labels from your workflow to Docker images
      labels = [
        "codeberg:docker://node:18-bullseye"
        "ubuntu-latest:docker://node:18-bullseye"
      ];

      settings = {
        runner = {
          capacity = 1; # Concurrent jobs allowed
          timeout = "3h";
        };
        container = {
          # Connect directly to the system Docker socket
          docker_host = "unix:///var/run/docker.sock";
          network = "bridge";
        };
      };
    };
  };
}
