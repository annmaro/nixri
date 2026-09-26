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

    cliamp = (inputs.cliamp.packages.${final.stdenv.hostPlatform.system}.default).overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (final.writeText "cliamp-allow-local.patch" ''
          --- a/luaplugin/api_http.go
          +++ b/luaplugin/api_http.go
          @@ -26,10 +26,6 @@
           	if ip == nil {
           		return fmt.Errorf("cannot resolve dial address %q", address)
           	}
          -	if ip.IsLoopback() || ip.IsPrivate() || ip.IsLinkLocalUnicast() ||
          -		ip.IsLinkLocalMulticast() || ip.IsMulticast() || ip.IsUnspecified() {
          -		return fmt.Errorf("blocked request to non-public address %s", ip)
          -	}
           	return nil
           }
        '')
      ];
    });
  };
}
