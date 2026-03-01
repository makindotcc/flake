{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = lib.collectNix ./. |> lib.remove ./default.nix;
}
// (lib.mkIf config.de.homemade.enable {
  environment.systemPackages = [ pkgs.adwaita-icon-theme ];

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
  services.blueman.enable = true;
})
