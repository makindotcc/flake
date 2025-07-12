{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.de.gnome.enable {
  environment.systemPackages = [ pkgs.imagemagick ];

  home-manager.sharedModules = [
    {
      programs.gnome-shell.extensions = [
        { package = pkgs.gnomeExtensions.search-light; }
      ];
    }
  ];
}
