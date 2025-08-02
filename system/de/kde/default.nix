{
  lib,
  config,
  ...
}:
{

  options.de.kde.enable = lib.mkEnableOption "Enable kde desktop environment." // {
    default = config.de.type == "kde";
  };

  config = lib.mkIf config.de.kde.enable {
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    services.desktopManager.plasma6.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };

    impermanence.normalUsers = {
      directories = [
        ".config/glib-2.0"
        ".config/gtk-3.0"
        ".config/kdeconnect"
        ".config/session"
        ".config/xsettingsd"
        ".local/share/konsole"
      ];
      files = [
        ".config/akregatorrc"
        ".config/baloofilerc"
        ".config/gtkrc"
        ".config/gtkrc-2.0"
        ".config/kactivitymanagerdrc"
        ".config/kactivitymanagerd-statsrc"
        ".config/kateschemarc"
        ".config/kcminputrc"
        ".config/kded5rc"
        ".config/khotkeysrc"
        ".config/kmixrc"
        ".config/konsolerc"
        ".config/kscreenlockerrc"
        ".config/ktimezonedrc"
        ".config/kwinrulesrc"
        ".config/kxkbrc"
        ".config/plasma-localerc"
        ".config/powermanagementprofilesrc"
        ".config/kwinoutputconfig.json"
      ]
      ++ (
        [
          ".config/kdeglobals"
          ".config/kglobalshortcutsrc"
          ".config/kwinrc"
          ".config/kconf_updaterc"
          ".config/plasma-org.kde.plasma.desktop-appletsrc"
          ".config/plasmashellrc"
          ".config/ksmserverrc"
          ".config/plasmanotifyrc"
          ".config/spectaclerc"
        ]
        |> builtins.map (path: {
          name = "kde-${lib.strings.removePrefix ".config/" path}";
          path = path;
          mode = "copy";
        })
      );
    };

    home-manager.sharedModules = [
      {
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            icon-theme = "breeze";
          };
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };
      }
    ];
  };
}
