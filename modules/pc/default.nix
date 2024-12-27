{
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # hw monitoring tools
    usbutils
    pciutils

    gparted
    mission-center

    # media
    yt-dlp
    ffmpeg_6-full
    krita
    clapper

    google-chrome

    # social
    (telegram-desktop.override { withWebkit = false; })
    signal-desktop
    discord # huj wam w dupe ? ciezko zbumpowac wersje przegladarki ?
    vesktop

    # hakowanie na ekranie
    burpsuite
    ida-free
    # binja https://gist.github.com/Ninja3047/256a0727e7ea09ab6c82756f11265ee1
    frida-tools

    mullvad-vpn
  ];

  programs = {
    wavemon.enable = true;
    obs-studio.enable = true;
  };

  home-manager.sharedModules = [ (import ./home.nix { inherit pkgs inputs; }) ];

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # environment.gnome.excludePackages = with pkgs; [
  #   # totem # "could not initialise opengl support" 😂😂😂 use clapper instead
  # ];
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };
  console.keyMap = "pl2";
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
