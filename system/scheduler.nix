{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.isDesktop {
  services.system76-scheduler.enable = config.services.desktopManager.gnome.enable;

  home-manager.sharedModules = lib.mkIf config.services.desktopManager.gnome.enable [
    {
      programs.gnome-shell.extensions = [
        { package = inputs.s76-scheduler-plugin.packages.${pkgs.system}.default; }
      ];
    }
  ];
}
