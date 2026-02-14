{ lib, config, ... }:
{
  imports = (lib.collectNix ./. |> lib.remove ./default.nix);

  hardware.usb.wakeupDisabled = lib.mkIf config.isLinux [
    {
      # logitech g pro superlight
      vendor = "046d";
      product = "c547";
    }
    {
      # Apple, Inc. Apple Watch Magnetic Charging Cable
      vendor = "05ac";
      product = "0503";
    }
  ];
}
