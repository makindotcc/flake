{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.signal.enable = lib.mkEnableOption "Signal desktop client" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.signal.enable {
    environment.systemPackages = [ pkgs.signal-desktop ];
    impermanence.normalUsers.directories = [ ".config/Signal" ];
  };
}
