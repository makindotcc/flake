{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.imagemagick ];

  home-manager.sharedModules = [
    {
      programs.gnome-shell.extensions = [
        { package = pkgs.gnomeExtensions.search-light; }
      ];
    }
  ];
}
