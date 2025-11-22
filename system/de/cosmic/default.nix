{
  lib,
  config,
  ...
}:
{
  options.de.cosmic.enable = lib.mkEnableOption "Enable cosmic desktop environment." // {
    default = config.de.type == "cosmic";
  };

  config = lib.mkIf config.de.cosmic.enable {
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic = {
      enable = true;
      xwayland.enable = true;
    };

    systemd.services.monitord.wantedBy = [ "multi-user.target" ];
    environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;

    impermanence.normalUsers.directories = [ ".config/cosmic" ];

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;

    home-manager.sharedModules = [
      {
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
          "org/gnome/desktop/wm/preferences" = {
            button-layout = " appmenu:minimize,maximize,close";
          };
        };
      }
    ];
  };
}
