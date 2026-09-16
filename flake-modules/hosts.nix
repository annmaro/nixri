{ inputs, self, ... }:

{
  flake.nixosConfigurations = {
    laptop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs self;
      };

      modules = [
        ../hosts/common.nix
        ../hosts/laptop
      ];
    };

    desktop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs self;
      };

      modules = [
        ../hosts/common.nix
        ../hosts/desktop
      ];
    };
  };
}
