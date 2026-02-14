{
  pkgs,
  config,
  lib,
  ...
}:
{
  environment.systemPackages = lib.mkIf config.isDesktop [
    pkgs.libnotify
    pkgs.alsa-utils
  ];
}
