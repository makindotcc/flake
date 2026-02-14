{ lib, config, ... }:
{
  imports = [
    ./cosmic
    ./gnome
    ./kde
    ./hyprland
    ./homemade
  ];

  options = {
    de.type = lib.mkOption {
      type = lib.types.enum [
        "gnome"
        "kde"
        "cosmic"
        "hyprland"
        "homemade"
        "none"
      ];
      default = if config.isDesktop then "kde" else "none";
      description = "The type of desktop environment to use.";
    };
  };

  config = lib.mkIf config.isDesktop {
    environment.sessionVariables = {
      # nicer font rendering
      FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
      # wayland in (most) electron apps
      NIXOS_OZONE_WL = "1";
    };

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
