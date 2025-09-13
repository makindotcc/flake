{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.mosh-client.enable = lib.mkEnableOption "Mosh client" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.mosh-client.enable {
    environment.systemPackages = [ pkgs.mosh ];
  };
}
