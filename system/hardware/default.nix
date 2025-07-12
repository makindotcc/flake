{ lib, config, ... }:
{
  imports = [
    ./nvidia.nix
    ./usb-wakeup-disable.nix
  ];

  hardware.usb.wakeupDisabled =
    lib.mkIf config.os == "linux" [
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
