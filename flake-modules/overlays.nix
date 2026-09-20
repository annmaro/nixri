{ inputs, ... }:

{
  flake.overlays.default = final: prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };

    helium = final.symlinkJoin {
      name = "helium-wrapped";
      paths = [ prev.helium ];
      buildInputs = [ final.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/helium \
          --add-flags "--ozone-platform-hint=auto"
      '';
    };
  };
}
