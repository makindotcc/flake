{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    hardware.razer.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable support for Razer devices via OpenRazer.";
    };
  };

  config = lib.mkIf config.hardware.razer.enable {
    hardware.openrazer = {
      enable = true;
      users = [ "user" ];
    };
    environment.systemPackages = [
      pkgs.openrazer-daemon
      pkgs.polychromatic
    ];
  };
}
