{
  pkgs,
  ...
}:
{
  imports = [
    ./sublime.nix
    ./urldebloater.nix
    ./kde-connect.nix
  ];

  environment.systemPackages = with pkgs; [
    # hw monitoring tools
    usbutils
    pciutils

    gparted

    eyedropper

    # media
    yt-dlp
    ffmpeg_6-full
    krita
    spotify

    # social
    (telegram-desktop.override { withWebkit = false; })
    signal-desktop
    discord # huj wam w dupe ? ciezko zbumpowac wersje przegladarki ?
    vesktop
    slack

    parsec-bin

    google-chrome
  ];

  programs = {
    obs-studio = {
      enable = true;
      package = (
        pkgs.obs-studio.override {
          cudaSupport = true;
        }
      );
    };
    wireshark.enable = true;
  };

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # congratulations you so braave and gatekeeped installer behind login page corporation final boss
  # virtualisation.vmware.host.enable = true;
}
