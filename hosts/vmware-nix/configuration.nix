{ config, pkgs, nixpkgs, ... }:

let
  stateVersion = "24.11";
in
{
  nixpkgs.config.allowUnfree = true;
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/system
      ../../modules/pc
      ../../modules/dev.nix
      ../../users/user
    ];
  home-manager.sharedModules = [ { home.stateVersion = stateVersion; }];

  networking.hostName = "vmware-nix";

  # desktop bloat

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.networkmanager.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = stateVersion;
}

