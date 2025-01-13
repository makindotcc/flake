{
  config,
  pkgs,
  ...
}:
let
  stateVersion = "24.11";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/pc
    ../../modules/nvidia
    ../../modules/gaming
    ../../modules/dev.nix
    ../../modules/docker.nix
    ../../modules/usb-wakeup-disable.nix
    ../../users/user
  ];
  home-manager.sharedModules = [ { home.stateVersion = stateVersion; } ];

  environment.systemPackages = with pkgs; [
    veracrypt
  ];

  networking.hostName = "pc-nixos";

  hardware.usb.wakeupDisabled = [
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

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  system.stateVersion = stateVersion;

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
