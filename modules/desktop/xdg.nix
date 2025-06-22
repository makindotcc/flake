{ ... }:
let
  # dzieki za liste https://github.com/surfaceflinger/flake/blob/master/modules/home/desktop/xdg.nix

  browser = [ "Firefox.desktop" ];
  photos = [ "org.gnome.Loupe.desktop" ];
  steam = [ "steam.desktop" ];
  music = [ "io.bassi.Amberol.desktop" ];
  text = [ "org.gnome.TextEditor.desktop" ];

  associations = {
    "application/pdf" = browser;
    "application/json" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/x-extension-xht" = browser;
    "application/x-extension-xhtml" = browser;
    "application/xhtml+xml" = browser;
    "text/html" = browser;

    "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
    "x-scheme-handler/steam" = steam;
    "x-scheme-handler/steamlink" = steam;

    # image formats
    "image/avif" = photos;
    "image/bmp" = photos;
    "image/gif" = photos;
    "image/heic" = photos;
    "image/jpeg" = photos;
    "image/png" = photos;
    "image/svg+xml" = photos;
    "image/tiff" = photos;
    "image/webp" = photos;
    "image/x-icon" = photos;

    # audio formats
    "audio/aac" = music;
    "audio/flac" = music;
    "audio/mpeg" = music;
    "audio/ogg" = music;
    "audio/opus" = music;
    "audio/wav" = music;
    "audio/x-ms-wma" = music;

    "text/csv" = text;
  };
in
{
  xdg.mimeApps = {
    enable = true;
    associations.added = associations;
    defaultApplications = associations;
  };
  # force overwrite=
  xdg.configFile."mimeapps.list".force = true;
}
