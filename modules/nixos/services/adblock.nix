{ inputs, ... }:

{
  imports = [
    inputs.stevenblack-hosts.nixosModule
    ./pihole.nix
  ];

  networking.stevenBlackHosts = {
    enable = true;
    blockSocial = false;
    blockFakenews = false;
    blockGambling = false;
    blockPorn = false;
  };
}
