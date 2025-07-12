{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.programs.parsec.enable = lib.mkEnableOption "Parsec remote desktop" // {
    default = config.isPersonalPuter;
  };

  config = lib.mkIf config.programs.parsec.enable {
    environment.systemPackages = [ pkgs.parsec-bin ];
    impermanence.normalUsers.directories = [
      ".parsec"
      ".parsec-persistent"
    ];
  };
}
