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
        ".config/kdedefaults"
        ".config/glib-2.0"
        ".config/gtk-3.0"
        ".config/kdeconnect"
        ".config/session"
        ".config/xsettingsd"
        ".local/share/konsole"
        ".local/share/kwalletd"
        ".local/share/baloo"
        ".local/share/dolphin"
        ".local/share/plasma"
      ];
      files = [
        ".config/akregatorrc"
        ".config/gtkrc"
        ".config/gtkrc-2.0"
        ".config/kactivitymanagerdrc"
        ".config/kactivitymanagerd-statsrc"
        ".config/kateschemarc"
        ".config/kcminputrc"
        ".config/khotkeysrc"
        ".config/kmixrc"
        ".config/konsolerc"
        ".config/kscreenlockerrc"
        ".config/ktimezonedrc"
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
          ".config/kwalletrc"
          ".config/kwinrulesrc"
          ".config/baloofilerc"
          ".config/krunnerrc"
          ".config/kded5rc"
          ".config/dolphinrc"
          ".config/plasmarc"
        ]
        |> builtins.map (path: {
          name = "kde-${lib.strings.removePrefix ".config/" path}";
          path = path;
          mode = "copy";
        })
      )
      ++ (
        [
          "./local/state/dolphinstaterc"
          "./local/state/plasmashellstaterc"
          "./local/state/kickerstaterc"
          "./local/state/katestaterc"
        ]
        |> builtins.map (path: {
          name = "kde-${lib.strings.removePrefix "./local/state/" path}";
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
