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
  };

  programs.gamemode.enable = true;
}
