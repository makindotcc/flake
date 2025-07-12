{
  config,
  ...
}:
let
  wallpaperHomePath = "Pictures/wallpaper.png";
  wallpaperUri = "file://${config.home.homeDirectory}/${wallpaperHomePath}";
in
{
  home.file.${wallpaperHomePath}.source = ../../wallpaper.png;

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = wallpaperUri;
      picture-uri-dark = wallpaperUri;
    };
    "org/gnome/desktop/screensaver/picture-uri" = {
      picture-uri = wallpaperUri;
    };
  };
}
