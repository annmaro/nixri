{ lib, fetchFromGitea, rustPlatform, pkg-config, openssl }:

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

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Standalone botguard token generator helper for RustyPipe";
    homepage = "https://github.com";
    license = licenses.agpl3Only;
    maintainers = [ ];
  };
}
