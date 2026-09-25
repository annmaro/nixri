{ lib, buildDotnetModule, dotnetCorePackages, mpv, podlinerSrc }:

buildDotnetModule {
  pname = "podliner";
  version = "1.0.0";

  src = podlinerSrc;

  projectFile = "Podliner.App/Podliner.App.csproj";

  # We have to use nugetDeps and generate the file via fetch-deps
  nugetDeps = ./nuget-deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ mpv ]}"
  ];
}
