{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./extensions/search-light.nix
    ./power-management.nix
    ./theme
  ];

  services = {
    xserver.enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  # https://discourse.nixos.org/t/gnome-display-manager-fails-to-login-until-wi-fi-connection-is-established/50513/15
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  environment.gnome.excludePackages = with pkgs; [
    totem # "could not initialise opengl support" 😂😂😂 use clapper instead
    # gnome-console
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
    egl-wayland
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
