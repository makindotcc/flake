{
  pkgs,
  pkgs-stable,
  lib,
  config,
  ...
}:
{
  imports = lib.collectNix ./. |> lib.remove ./default.nix;

  environment.systemPackages = [
    pkgs.git
    pkgs.wget
    pkgs.tmux
    pkgs.bat
    pkgs.file
    pkgs.ncdu
    pkgs.ouch
    pkgs.bottom
    pkgs.fastfetch
    pkgs.psmisc
    pkgs.doggo
    pkgs.inetutils
    pkgs.speedtest-go
    pkgs.ripgrep
  ]
  ++ lib.optionals config.isPersonalPuter [
    pkgs.yt-dlp
    pkgs.ffmpeg_6-full
    pkgs.nmap
    pkgs.krita
  ]
  ++ lib.optionals (config.isLinux && config.isPhysical) [
    pkgs.usbutils
    pkgs.pciutils
  ]
  ++ lib.optionals (config.isLinux && config.isDesktop) [
    pkgs.gparted
    pkgs.fsearch
    pkgs.adw-gtk3
    pkgs.amberol
    pkgs.mission-center
    pkgs-stable.clapper
    pkgs.eyedropper
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  services.vnstat.enable = config.isLinux;
}
