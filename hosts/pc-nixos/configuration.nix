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
  ];

  isDesktop = true;
  isPhysical = true;
  dev.full = true;
  gaming.full = true;
  wine.enable = true;
  docker.enable = true;
  hardware.nvidia.enable = true;

  environment.systemPackages = with pkgs; [
    veracrypt
    ntfs3g
    (ollama.override {
      acceleration = "cuda";
    })
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

  home-manager.sharedModules = [ { home.stateVersion = stateVersion; } ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  system.stateVersion = stateVersion;

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
