{
  pkgs,
  pkgs-stable,
  inputs,
  ...
}:
{
  imports = [
    ./programs/sublime.nix
  ];

  environment.systemPackages =
    (with pkgs; [
      mission-center
      fsearch
      adw-gtk3
      google-chrome
      ghostty
      ngrok
      imagemagick # used by gnome extension "search light" for bg blur
      amberol # music player
    ])
    ++ (with pkgs-stable; [
      clapper
    ]);

  home-manager.sharedModules = [
    ./home.nix
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
