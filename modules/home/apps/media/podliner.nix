{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    (buildDotnetModule {
      pname = "podliner";
      version = "1.0.0"; 
      
      # Use the flake input directly instead of fetchFromGitHub
      src = inputs.podliner; 

      projectFile = "Podliner.App/Podliner.App.csproj";
      
      # In modern Nixpkgs, you can use nugetHash instead of a separate deps file.
      # Start with a fake hash like below, build it, and Nix will error and tell you the real hash!
      nugetHash = pkgs.lib.fakeHash;
      
      dotnet-sdk = dotnetCorePackages.sdk_9_0;
      dotnet-runtime = dotnetCorePackages.runtime_9_0;

      # Podliner shells out to external media players (like mpv, ffplay, or vlc).
      # Wrap the executable so it can find your preferred player.
      makeWrapperArgs = [
        "--prefix PATH : ${lib.makeBinPath [ pkgs.mpv ]}"
      ];
    })
  ];
}
