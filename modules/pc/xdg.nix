{ pkgs, ... }:
let
  steam = [ "steam.desktop" ];

  associations = {
    "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
    "x-scheme-handler/steam" = steam;
    "x-scheme-handler/steamlink" = steam;
  };
in
{
  xdg.mimeApps = {
    enable = true;
    associations.added = associations;
    defaultApplications = associations;
  };
}
