{ ... }:

{
  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        # PDFs
        "application/pdf" = [
          "io.github.JakubMelka.Pdf4qt.Pdf4QtViewer.desktop"
          "pdf4qtviewer.desktop"
        ];
        "application/x-pdf" = [
          "io.github.JakubMelka.Pdf4qt.Pdf4QtViewer.desktop"
          "pdf4qtviewer.desktop"
        ];

        # Web browser
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "application/xhtml+xml" = [ "firefox.desktop" ];

        # Text files
        "text/plain" = [ "dev.duxlabs.shell.notepad.desktop" ];
        "text/markdown" = [ "dev.duxlabs.shell.notepad.desktop" ];

        # Images and video
        "image/png" = [
          "org.nomacs.ImageLounge.desktop"
          "nomacs.desktop"
        ];
        "image/jpeg" = [
          "org.nomacs.ImageLounge.desktop"
          "nomacs.desktop"
        ];
        "image/gif" = [
          "org.nomacs.ImageLounge.desktop"
          "nomacs.desktop"
        ];
        "image/webp" = [
          "org.nomacs.ImageLounge.desktop"
          "nomacs.desktop"
        ];
        "image/bmp" = [
          "org.nomacs.ImageLounge.desktop"
          "nomacs.desktop"
        ];
        "image/tiff" = [
          "org.nomacs.ImageLounge.desktop"
          "nomacs.desktop"
        ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/mkv" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];

        # Archives
        "application/zip" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-rar" = [ "org.gnome.FileRoller.desktop" ];

        # Folders (file manager)
        "inode/directory" = [ "thunar.desktop" ];
      };
    };
  };
}
