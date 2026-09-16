{ autoPatchelfHook
, alsa-lib
, chromaprint
, dbus
, fetchurl
, gcc
, glibc
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "rmpd";
  version = "0.7.0";

  src = fetchurl {
    url = "https://github.com/M0Rf30/rmpd/releases/download/${version}/rmpd-${version}-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "1q21qiikv8smiz7ppz2462nwd60s1hr09rm0wskkgyff9nqx0phm";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    alsa-lib
    chromaprint
    gcc.cc.lib
    glibc
    dbus
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp rmpd $out/bin/
    chmod +x $out/bin/rmpd
  '';
}
