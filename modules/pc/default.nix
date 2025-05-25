{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./programs/urldebloater.nix
    # congratulations you so braave and gatekeeped installer behind login page
    # ./programs/vmware.nix
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
    ngrok
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

  services.scx = {
    enable = true;
    scheduler = "scx_bpfland";
  };

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  home-manager.sharedModules = [
    ./xdg.nix
  ];
}
