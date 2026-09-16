{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # The desktop host uses an AMD GPU. Its generated hardware file should be
  # replaced with the output of nixos-generate-config on the desktop machine.
  systemSettings.videoDriver = "amdgpu";
}
