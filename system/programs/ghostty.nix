{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.ghostty.enable = lib.mkEnableOption "Ghostty terminal" // {
    default = config.isDesktop;
  };
  config = lib.mkIf config.programs.ghostty.enable {
    environment.systemPackages = [ pkgs.ghostty ];
  };
}
