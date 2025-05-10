{
  pkgs,
  inputs,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      mutter = prev.mutter.overrideAttrs (old: {
        src = inputs.mutter-triple-buffering-src;
        preConfigure = ''
          cp -a "${inputs.gvdb-src}" ./subprojects/gvdb
        '';
      });
    })
  ];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    totem # "could not initialise opengl support" 😂😂😂 use clapper instead
    gnome-console
    epiphany
    evince
    gnome-maps
    gnome-music
    gnome-photos
    gnome-tour
    orca
    yelp
  ];

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-screenshot
  ];
  home-manager.sharedModules = [
    (
      {
        lib,
        ...
      }:
      (import ./home.nix { inherit lib pkgs inputs; })
    )
  ];
}
