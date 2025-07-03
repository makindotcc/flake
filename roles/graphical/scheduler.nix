{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  services.system76-scheduler.enable = true;

  home-manager.sharedModules = lib.mkIf config.services.desktopManager.gnome.enable [
    {
      programs.gnome-shell.extensions = [
        { package = inputs.s76-scheduler-plugin.packages.${pkgs.system}.default; }
      ];
    }
  ];
}
