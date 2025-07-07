_:
let
  stateVersion = "25.05";
in
{
  imports = [
    ../../roles/system
    ./hardware-configuration.nix

    ../../users/makin
    ../../users/remote-deploy

    ./buzkaaclicker
    ./web.nix
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
