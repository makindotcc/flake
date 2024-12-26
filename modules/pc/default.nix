{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # hw monitoring tools
    wavemon
    usbutils
    pciutils

    # media
    yt-dlp
    ffmpeg_6-full

    # gui
    krita
  ];
}
