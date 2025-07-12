{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./desktop
  ];

  environment.systemPackages =
    [
      pkgs.yt-dlp
      pkgs.ffmpeg_6-full
    ]
    ++ lib.optionals config.isPhysical [
      pkgs.usbutils
      pkgs.pciutils
    ];
}
