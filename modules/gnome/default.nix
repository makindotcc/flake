{
  pkgs,
  inputs,
  ...
}:
{
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    totem # "could not initialise opengl support" 😂😂😂 use clapper instead
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
