{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # The laptop is the default system and uses its integrated Intel graphics.
  systemSettings = {
    hostname = "nixri";
    videoDriver = "intel";
  };
}
