{
  pkgs,
  pkgs-stable,
  inputs,
  ...
}:
{
  imports = [
    ./programs/sublime.nix
    # congratulations you so braave and gatekeeped installer behind login page
    # ./programs/vmware.nix
    ./localcerts.nix
    ../downloadram.nix
  ];

  environment.systemPackages = with pkgs; [
    # hw monitoring tools
    usbutils
    pciutils

    gparted
    mission-center
    fsearch

    eyedropper

    adw-gtk3

    # media
    yt-dlp
    ffmpeg_6-full
    krita
    clapper
    spotify
    amberol

    google-chrome

    # social
    (telegram-desktop.override { withWebkit = false; })
    signal-desktop
    discord # huj wam w dupe ? ciezko zbumpowac wersje przegladarki ?
    vesktop
    slack

    # hakowanie na ekranie
    burpsuite
    ida-free
    # binja https://gist.github.com/Ninja3047/256a0727e7ea09ab6c82756f11265ee1
    frida-tools
    # jadx
    vscode
    jetbrains.idea-community-bin

    ghostty

    mongodb-compass
    parsec-bin
    ngrok

    imagemagick # used by gnome extension "search light" for bg blur
    ])
    ++ (with pkgs-stable; [
      clapper
    ]);

  programs = {
    wavemon.enable = true;
    obs-studio.enable = true;
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
    (
      {
        lib,
        ...
      }:
      (import ./home.nix { inherit lib pkgs inputs; })
    )
  ];

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

  environment.sessionVariables = {
    # nicer font rendering
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    # wayland in (most) electron apps
    NIXOS_OZONE_WL = "1";
  };

  fonts = {
    enableDefaultPackages = true;
    packages = [
      inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd
      inputs.apple-fonts.packages.${pkgs.system}.sf-mono-nerd
      inputs.apple-fonts.packages.${pkgs.system}.ny-nerd
      inputs.apple-emoji-linux.packages.${pkgs.system}.apple-emoji-linux
      pkgs.comic-mono
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "SFRounded Nerd Font"
        ];
        serif = [
          "SFRounded Nerd Font"
        ];
        monospace = [ "SFMono Nerd Font" ];
        emoji = [ "Apple Color Emoji" ];
      };
      useEmbeddedBitmaps = true;
    };
  };

  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };
  console.keyMap = "pl2";
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
