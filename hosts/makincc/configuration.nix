_:
let
  stateVersion = "25.05";
in
{
  imports = [
    ./hardware-configuration.nix

    ../../system
    ../../users/makin
    ../../users/remote-deploy

    ./buzkaaclicker
    ./web.nix
    ./antibridge.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.timeout = 15;
  boot.loader.grub.devices = [ "/dev/sda" ];

  networking.hostName = "makincc";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      8080
    ];
    allowedUDPPorts = [ ];
    allowPing = false;
  };

  system.stateVersion = stateVersion;
  home-manager.sharedModules = [ { home.stateVersion = stateVersion; } ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      GatewayPorts = "yes";
    };
  };

  programs.mosh = {
    enable = true;
    openFirewall = true;
  };
}
