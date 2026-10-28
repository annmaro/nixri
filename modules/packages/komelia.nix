{
  lib,
  fetchurl,
  appimageTools,
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
