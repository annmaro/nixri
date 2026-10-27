{ lib, fetchurl, fetchFromGitea, rustPlatform, pkg-config, openssl }:

let
  librusty_v8 = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v130.0.7/librusty_v8_release_x86_64-unknown-linux-gnu.a.gz";
    hash = "sha256-pkdsuU6bAkcIHEZUJOt5PXdzK424CEgTLXjLtQ80t10=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "rustypipe-botguard";
  version = "0.1.2";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "ThetaDev";
    repo = "rustypipe-botguard";
    rev = "v${version}";
    hash = "sha256-vUkTCRQvaH9hoaFNm2qgBZ4+f15wNBmctC/JDKF7W6E=";
  };

  # This tells Nix to build dependencies in an isolated sandbox.
  # Leave this hash blank initially; Nix will throw an error telling you the correct hash.
  cargoHash = "sha256-hPKjdP4X/iNNUlD8sjv7pKeRoDD8+Pj2xp1h8XOd/bs=";

  env.RUSTY_V8_ARCHIVE = librusty_v8;
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Standalone botguard token generator helper for RustyPipe";
    homepage = "https://github.com";
    license = licenses.agpl3Only;
    maintainers = [ ];
  };
}
