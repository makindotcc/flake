{
  pkgs,
  ...
}:
let
  stateVersion = "24.11";
in
{
  imports = [
    ./hardware-configuration.nix

    ../../system
    ../../users/user

    ./localcerts.nix
    ./makincc-builder.nix
    ./tailscale.nix
  ];

  isDesktop = true;
  isPhysical = true;
  dev.full = true;
  gaming.full = true;
  wine.enable = true;
  docker.enable = true;
  hardware.nvidia.enable = true;
  de.type = "kde";

  environment.systemPackages = with pkgs; [
    veracrypt
    ntfs3g
    ngrok
  ];

  networking.hostName = "pc-nixos";

  services.openssh = {
    enable = true;
    ports = [ 2135 ];
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  home-manager.sharedModules = [
    {
      services.pueue.enable = true;
      home.stateVersion = stateVersion;
    }
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  system.stateVersion = stateVersion;

  boot.kernelPackages = pkgs.linuxPackages_6_15; # downgrade for vmware
}
