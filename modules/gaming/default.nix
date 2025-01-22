{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    lunar-client
    (prismlauncher.override {
      jdks = [
        jdk8
        jdk21
      ];
    })

    lutris

    dxvk
    mangohud
  ];

  programs.steam = {
    enable = true;
    extest.enable = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    extraPackages = with pkgs; [
      steamtinkerlaunch
      winetricks
    ];
    gamescopeSession.enable = true;

    # remotePlay.openFirewall = true;
    # localNetworkGameTransfers.openFirewall = true;
  };

  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      47984
      47989
      47990
      48010
    ];
    allowedUDPPortRanges = [
      {
        from = 47998;
        to = 48000;
      }
      {
        from = 8000;
        to = 8010;
      }
    ];
  };

  programs.gamemode.enable = true;
}
