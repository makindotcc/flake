{
  pkgs,
  config,
  lib,
  ...
}:
{
  # 'de' it isnt a de... but it was worth a test
  options.de.hyprland.enable = lib.mkEnableOption "Enable Hyprland window manager." // {
    default = config.de.type == "hyprland";
  };

  config = lib.mkIf config.de.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    environment.systemPackages = [
      pkgs.kitty
      pkgs.rofi
    ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    impermanence.normalUsers.directories = [ ".config/hypr" ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
  };
}
