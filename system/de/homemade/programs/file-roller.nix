{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.de.homemade.enable {
  environment.systemPackages = [
    pkgs.file-roller
  ];
}
