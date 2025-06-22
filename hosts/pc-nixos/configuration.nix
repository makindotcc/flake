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
    ../../modules/desktop
    ../../modules/pc
    ../../modules/de/gnome
    ../../modules/nvidia.nix
    ../../modules/gaming.nix
    ../../modules/dev
    ../../modules/docker.nix
    ../../modules/usb-wakeup-disable.nix
    ../../modules/wine.nix
    ../../users/user
  ];
  home-manager.sharedModules = [ { home.stateVersion = stateVersion; } ];

  environment.systemPackages = with pkgs; [
    veracrypt
    ntfs3g
    (ollama.override {
      acceleration = "cuda";
    })
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

  services.openssh = {
    enable = true;
    ports = [ 2135 ];
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  system.stateVersion = stateVersion;

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
