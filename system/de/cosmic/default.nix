{
  inputs,
  pkgs,
  ...
}:
{
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     cosmic-launcher = prev.cosmic-launcher.overrideAttrs (old: rec {
  #       src = prev.fetchFromGitHub {
  #         owner = "makindotcc";
  #         repo = "cosmic-launcher";
  #         rev = "814caca135edd8a0c17c766efefc6092b813fb3a";
  #         hash = "sha256-1k4xwGpnJj2JFe25t6D/MRuY11olsvalh4wQqoAm4lQ=";
  #       };
  #       cargoDeps = prev.rustPlatform.fetchCargoVendor {
  #         inherit src;
  #         hash = "sha256-9N9B5eb3FkONTwaFv3+trCf9K0K0l8tE/Db/RN+UHMo=";
  #       };
  #     });
  #   })
  # ];

  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic = {
    enable = true;
    xwayland.enable = true;
  };

  # systemd.packages = [ pkgs.observatory ];
  # systemd.services.monitord.wantedBy = [ "multi-user.target" ];
  # environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
}
