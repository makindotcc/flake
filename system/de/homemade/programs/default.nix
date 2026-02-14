{ pkgs, lib, ... }:
{
  imports = lib.collectNix ./. |> lib.remove ./default.nix;

  environment.systemPackages = [ pkgs.adwaita-icon-theme ];

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
  services.blueman.enable = true;
}
