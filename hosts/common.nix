{ inputs, self, ... }:

{
  nixpkgs.overlays = [
    inputs.helium.overlays.default
    self.overlays.default
  ];

  imports = [
    ../modules/core/settings.nix
    ../modules/nixos/desktop/niri.nix
    ../modules/nixos/desktop/sddm.nix
    (inputs.import-tree ../modules/nixos/core)
    (inputs.import-tree ../modules/nixos/hardware)
    (inputs.import-tree ../modules/nixos/services)
  ];
}
