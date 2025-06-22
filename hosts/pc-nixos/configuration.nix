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
    ../../roles/physical
    ../../modules/dev
    ../../modules/gaming.nix
    ../../modules/wine.nix
    ../../users/user

    ./localcerts.nix
  ];

  dev.full = true;
  gaming.full = true;

  virtualisation.docker.enable = true;

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
