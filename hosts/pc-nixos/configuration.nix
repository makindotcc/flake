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
    # ./tailscale.nix
    ./remote-access.nix
    ./rgb.nix
    ./backup.nix
    ./ollama.nix
    ./tabby.nix
  ];

  isDesktop = true;
  isPhysical = true;
  dev.full = true;
  gaming.full = true;
  wine.enable = true;
  docker.enable = true;
  hardware.nvidia.enable = true;
  de.type = "kde";
  # de.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    ntfs3g
    ngrok
  ];

  networking.hostName = "pc-nixos";

  home-manager.sharedModules = [
    {
      services.pueue.enable = true;
      home.stateVersion = stateVersion;
    }
  ];

  networking.firewall = {
    enable = true;
    # playing with own tcp stack in my scanner
    extraCommands = ''
      iptables -A INPUT -p tcp --dport 41351 -j DROP
    '';
    allowedTCPPorts = [
      8080
    ];
  };

  networking.hosts = {
    "13.56.237.8" = [ "lendwyse.com" ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  system.stateVersion = stateVersion;
}
