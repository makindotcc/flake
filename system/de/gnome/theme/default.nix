{
  self,
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.de.gnome.enable {
  home-manager.sharedModules = [
    (all: import ./wallpaper.nix (all // { inherit self; }))
    (_: import ./icons.nix { inherit self pkgs; })
  ];
}
