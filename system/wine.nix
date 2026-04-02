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
      pkgs.wineWow64Packages.stable
      pkgs.winetricks
      pkgs.wineWow64Packages.waylandFull
    ];

    impermanence.normalUsers.directories = [ ".wine" ];
  };
}
