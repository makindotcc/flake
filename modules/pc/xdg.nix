{ ... }:
let
  browser = [ "Firefox.desktop" ];

  associations = {
    "application/pdf" = browser;
  };
in
{
  xdg.mimeApps = {
    enable = true;
    associations.added = associations;
    defaultApplications = associations;
  };
}
