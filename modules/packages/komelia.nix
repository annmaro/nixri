{
  lib,
  fetchurl,
  appimageTools,
  xwayland,
  xwayland-satellite,
}:

let
  pname = "komelia";
  version = "0.20.0";

  src = fetchurl {
    name = "Komelia-${version}-linux-x64.AppImage";
    url = "https://github.com/Snd-R/Komelia/releases/download/${version}/Komelia-${version}-linux-x64.AppImage";
    hash = "sha256-iDEyIJ2kCDd1mYtoXMlAMWOuhaE0fB4Hgm3XxB82Usg=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    # Graphical / GPU acceleration for Compose Multiplatform / Skia
    libGL
    libGLU
    vulkan-loader
    wayland
    libxkbcommon
    libx11
    libxcursor
    libxrandr
    libxi
    libxext
    libXxf86vm
    mesa

    # WebKitGTK / EPUB webview
    webkitgtk_4_1
    libsoup_3
    glib-networking

    # Image decoding / libvips dependencies
    vips
    libexif
    pcre2
    libwebp
    dav1d
    libheif
    libjxl
    libde265
    libhwy
    lcms2
    openjpeg
    libpng
    libjpeg
    libtiff
  ];

  extraInstallCommands = ''
    install -Dm 644 ${appimageContents}/Komelia.desktop -t $out/share/applications/
    install -Dm 644 ${appimageContents}/Komelia.png $out/share/icons/hicolor/256x256/apps/komelia.png
    install -Dm 644 ${appimageContents}/Komelia.png $out/share/icons/hicolor/256x256/apps/Komelia.png

    substituteInPlace $out/share/applications/Komelia.desktop \
      --replace-fail 'Exec=Komelia' 'Exec=komelia' \
      --replace-fail 'Icon=Komelia' 'Icon=komelia'

    echo "StartupWMClass=Komelia" >> $out/share/applications/Komelia.desktop

    mv $out/bin/komelia $out/bin/.komelia-unwrapped
    cat > $out/bin/komelia << 'EOF'
#!/bin/sh

is_socket_alive() {
  perl -MSocket -e '
    my $path = $ARGV[0];
    socket(my $s, PF_UNIX, SOCK_STREAM, 0) or exit 1;
    exit(connect($s, sockaddr_un($path)) ? 0 : 1);
  ' "$1" 2>/dev/null
}

if [ -z "$DISPLAY" ]; then
  for sock in /tmp/.X11-unix/X*; do
    if [ -S "$sock" ] && is_socket_alive "$sock"; then
      disp="''${sock##*/X}"
      if [ -n "$disp" ] && [ "$disp" != "*" ]; then
        export DISPLAY=":$disp"
        break
      fi
    fi
  done
fi

XWS_PID=""
if [ -z "$DISPLAY" ] && [ -n "$WAYLAND_DISPLAY" ]; then
  disp_num=12
  while :; do
    sock="/tmp/.X11-unix/X$disp_num"
    if [ -e "$sock" ]; then
      if ! is_socket_alive "$sock"; then
        rm -f "$sock" 2>/dev/null || true
        break
      fi
      disp_num=$((disp_num + 1))
    else
      break
    fi
  done

  PATH="@xwaylandPath@:$PATH" @xwaylandSatelliteBin@ ":$disp_num" &
  XWS_PID=$!

  for _ in $(seq 1 30); do
    if is_socket_alive "/tmp/.X11-unix/X$disp_num"; then
      break
    fi
    sleep 0.1
  done

  export DISPLAY=":$disp_num"
fi

cleanup() {
  if [ -n "$XWS_PID" ]; then
    kill "$XWS_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

"@out@/bin/.komelia-unwrapped" "$@"
EXIT_CODE=$?
cleanup
trap - EXIT INT TERM
exit $EXIT_CODE
EOF
    substituteInPlace $out/bin/komelia \
      --subst-var-by xwaylandPath "${xwayland}/bin" \
      --subst-var-by xwaylandSatelliteBin "${xwayland-satellite}/bin/xwayland-satellite" \
      --subst-var-by out "$out"
    chmod +x $out/bin/komelia
  '';

  meta = with lib; {
    description = "Desktop client for Komga";
    homepage = "https://github.com/Snd-R/Komelia";
    changelog = "https://github.com/Snd-R/Komelia/releases/tag/${version}";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "komelia";
  };
}
