{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.wine.enable = lib.mkEnableOption "Enable Wine support";

  config = lib.mkIf config.wine.enable {
    environment.systemPackages = [
      pkgs.wineWowPackages.stable
      pkgs.winetricks
      pkgs.wineWowPackages.waylandFull
    ];
  };
}
