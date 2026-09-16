{ inputs, ... }:

{
  imports = [
    inputs.stevenblack-hosts.nixosModule
    ./privoxy.nix
  ];

  networking.stevenBlackHosts = {
    enable = true;
    blockSocial = false;
    blockFakenews = false;
    blockGambling = false;
    blockPorn = false;
  };
}
