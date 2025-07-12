{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.chrome.enable = lib.mkEnableOption "Google Chrome browser" // {
    default = config.isDesktop;
  };
  config = lib.mkIf config.programs.chrome.enable {
    environment.systemPackages = [ pkgs.google-chrome ];
    impermanence.normalUsers.directories = [ ".config/google-chrome" ];
  };
}
