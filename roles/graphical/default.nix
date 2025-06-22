{
  pkgs,
  pkgs-stable,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../system
    ./de/gnome
    ./programs
    ./scheduler.nix
    ./xdg.nix
  ];

  options = {
    debloated = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = {
    environment.systemPackages =
      (with pkgs; [
        fsearch
        adw-gtk3
        ghostty
        amberol # music player
      ])
      ++ (with pkgs-stable; [
        clapper
      ]);

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
  };
}
