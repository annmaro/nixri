{ pkgs ? import <nixpkgs> {} }:

let
  podliner-src = pkgs.fetchFromGitHub {
    owner = "timkicker";
    repo = "podliner";
    rev = "main";
    hash = "sha256-4O0x4V+0c4C/f5m1TfE4q5O1n5m6K7K7W1C8Z8c7W8g="; # I will replace this with fakeHash and get it
  };
in
pkgs.buildDotnetModule {
  pname = "podliner";
  version = "1.0.0";
  src = podliner-src;
  projectFile = "Podliner.App/Podliner.App.csproj";
  dotnet-sdk = pkgs.dotnetCorePackages.sdk_9_0;
  dotnet-runtime = pkgs.dotnetCorePackages.runtime_9_0;
}
