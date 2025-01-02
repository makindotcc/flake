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
    fsearch

    eyedropper

    gnome-tweaks
    adw-gtk3

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
    vscode

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

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  environment.gnome.excludePackages = with pkgs; [
    totem # "could not initialise opengl support" 😂😂😂 use clapper instead
  ];
  environment.sessionVariables = {
    # nicer font rendering
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    # wayland in (most) electron apps
    NIXOS_OZONE_WL = "1";
  };
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  fonts = {
    enableDefaultPackages = true;
    packages = [
      inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd
      inputs.apple-fonts.packages.${pkgs.system}.sf-mono-nerd
      inputs.apple-fonts.packages.${pkgs.system}.ny-nerd
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [
          "SFRounded Nerd Font"
        ];
        serif = [
          "SFRounded Nerd Font"
        ];
        monospace = [ "SFMono Nerd Font" ];
      };
    };
  };

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
