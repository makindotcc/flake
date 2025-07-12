{ self, pkgs, ... }:
{
  home-manager.sharedModules = [
    (all: import ./wallpaper.nix (all // { inherit self; }))
    (_: import ./icons.nix { inherit self pkgs; })
  ];
}
