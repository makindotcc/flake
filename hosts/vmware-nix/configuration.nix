{
  config,
  pkgs,
  nixpkgs,
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
    ../../modules/dev.nix
    ../../users/user
  ];
  home-manager.sharedModules = [ { home.stateVersion = stateVersion; } ];

  networking.hostName = "vmware-nix";

  # desktop bloat

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.networkmanager.enable = true;

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = stateVersion;
}
