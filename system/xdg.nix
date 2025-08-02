{
  lib,
  config,
  ...
}:
let
  # dzieki za liste https://github.com/surfaceflinger/flake/blob/master/modules/home/desktop/xdg.nix

  browser = [ "firefox.desktop" ];
  photos = [ "org.gnome.Loupe.desktop" ];
  steam = [ "steam.desktop" ];
  music = [ "io.bassi.Amberol.desktop" ];
  text = [ "org.gnome.TextEditor.desktop" ];

  steamHandlers = lib.optionalAttrs config.programs.steam.enable {
    "x-scheme-handler/steam" = steam;
    "x-scheme-handler/steamlink" = steam;
  };

  telegramPresent = builtins.elem "telegram-desktop" (
    map lib.getName config.environment.systemPackages
  );
  telegramHandlers = lib.optionalAttrs telegramPresent {
    "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
  };

  associations =
    {
      "application/pdf" = browser;
      "application/json" = browser;
      "application/x-extension-htm" = browser;
      "application/x-extension-html" = browser;
      "application/x-extension-shtml" = browser;
      "application/x-extension-xht" = browser;
      "application/x-extension-xhtml" = browser;
      "application/xhtml+xml" = browser;
      "text/html" = browser;

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
    }
    // steamHandlers
    // telegramHandlers;

  homeConfig = {
    xdg.mimeApps = {
      enable = true;
      associations.added = associations;
      defaultApplications = associations;
    };
    # force overwrite=
    xdg.configFile."mimeapps.list".force = true;
  };
in
{
  home-manager.sharedModules = lib.mkIf config.isDesktop [ homeConfig ];
}
