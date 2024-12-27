{ config, pkgs, ... }:
let
  stateVersion = "24.11";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/pc
    ../../modules/dev.nix
    ../../users/user
    ../../modules/nvidia
  ];
  home-manager.sharedModules = [ { home.stateVersion = stateVersion; } ];

  environment.systemPackages = with pkgs; [
    veracrypt
  ];

  networking.hostName = "pc-nixos";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  system.stateVersion = stateVersion;

  boot.kernelPackages = pkgs.linuxPackages_6_12;
}
