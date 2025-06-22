# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:
let
  stateVersion = "25.05";
in
{
  imports = [
    ../../roles/system
    ./hardware-configuration.nix

    ../../users/makin
  ];

  boot.loader.grub.enable = true;
  boot.loader.timeout = 15;
  boot.loader.grub.devices = [ "/dev/sda" ];

  networking.hostName = "makincc";

  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
    ];
    allowedUDPPorts = [ ];
    allowPing = false;
  };

  system.stateVersion = stateVersion;
  home-manager.sharedModules = [ { home.stateVersion = stateVersion; } ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };
}
