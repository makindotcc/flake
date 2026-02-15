{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./programs
  ];

  options.de.homemade.enable = lib.mkEnableOption "Enable homemade desktop environment." // {
    default = config.de.type == "homemade";
  };

  config = lib.mkIf config.de.homemade.enable {
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common.default = [ "gtk" ];
        labwc = {
          default = [
            "wlr"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Settings" = "gtk";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      labwc
      fuzzel
      gsettings-desktop-schemas
      glib
      qt6Packages.qt6ct
      libsForQt5.qt5ct
      wlr-randr
      grim
      slurp
      wl-clipboard
      blueman
      loupe
      (writeShellScriptBin "launch-wrapper" ''
        echo "$(date): args=$*" >> /tmp/launch-wrapper.log
        echo "$(date): PATH=$PATH" >> /tmp/launch-wrapper.log
        cmd="$*"
        exec bash -l -c "$cmd"
      '')
    ];

    services.displayManager.sessionPackages = [ pkgs.labwc ];
    security.pam.services.swaylock = { };
    security.pam.services.sddm.enableGnomeKeyring = true;

    security.polkit.enable = true;
    programs.dconf.enable = true;
    services.gnome.gnome-keyring.enable = true;

    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "labwc";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_STYLE_OVERRIDE = "Fusion";
    };

    # impermanence

    home-manager.sharedModules = [
      (
        {
          config,
          pkgs,
          lib,
          ...
        }:
        let
          fuzzelToggle = "sh -c 'qs ipc --pid $(pgrep -f bin/quickshell | head -1) call fuzzel toggle'";
          displayModeToggle = "sh -c 'qs ipc --pid $(pgrep -f bin/quickshell | head -1) call displayMode toggle'";
        in
        {
          programs.swaylock = {
            enable = true;
            settings = {
              color = "101010";
              font-size = 24;
              indicator-idle-visible = false;
              line-color = "ffffff";
              show-failed-attempts = true;
            };
          };

          programs.quickshell = {
            enable = true;
            # configs.default = ./shell;
          };

          programs.fuzzel = {
            enable = true;
            settings = {
              main = {
                font = "monospace:size=12";
                terminal = "ghostty -e";
                launch-prefix = "sh -c 'exec \"$@\" >/dev/null 2>&1' --";
              };
              colors = {
                background = "1e1e2eff";
                text = "cdd6f4ff";
                selection = "45475aff";
                selection-text = "cdd6f4ff";
                border = "89b4faff";
              };
              key-bindings = {
                delete-line-backward = "Control+a";
                cursor-home = "Control+u";
              };
            };
          };

          xdg.configFile."quickshell/shell.qml".source =
            config.lib.file.mkOutOfStoreSymlink "/home/user/.config/nix/system/de/homemade/shell/shell.qml";

          xdg.configFile."quickshell/wallpaper.png".source = ../wallpaper.png;

          # Qt6ct dark theme (catppuccin mocha)
          xdg.configFile."qt6ct/qt6ct.conf".text = ''
            [Appearance]
            color_scheme_path=${pkgs.qt6Packages.qt6ct}/share/qt6ct/colors/darker.conf
            custom_palette=true
            icon_theme=Adwaita
            standard_dialogs=default
            style=Fusion

            [Fonts]
            fixed="Sans Serif,10,-1,5,50,0,0,0,0,0"
            general="Sans Serif,10,-1,5,50,0,0,0,0,0"

            [Palette]
            active_colors=#ffcdd6f4, #ff1e1e2e, #ff45475a, #ff313244, #ff181825, #ff11111b, #ffcdd6f4, #ffffffff, #ffcdd6f4, #ff1e1e2e, #ff1e1e2e, #ff585b70, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff1e1e2e, #ffcdd6f4, #ff181825, #ffcdd6f4, #80cdd6f4
            disabled_colors=#ff6c7086, #ff1e1e2e, #ff45475a, #ff313244, #ff181825, #ff11111b, #ff6c7086, #ffffffff, #ff6c7086, #ff1e1e2e, #ff1e1e2e, #ff585b70, #ff45475a, #ff6c7086, #ff89b4fa, #fff38ba8, #ff1e1e2e, #ffcdd6f4, #ff181825, #ffcdd6f4, #80cdd6f4
            inactive_colors=#ffcdd6f4, #ff1e1e2e, #ff45475a, #ff313244, #ff181825, #ff11111b, #ffcdd6f4, #ffffffff, #ffcdd6f4, #ff1e1e2e, #ff1e1e2e, #ff585b70, #ff89b4fa, #ff1e1e2e, #ff89b4fa, #fff38ba8, #ff1e1e2e, #ffcdd6f4, #ff181825, #ffcdd6f4, #80cdd6f4
          '';

          # Labwc dark theme (catppuccin mocha)
          xdg.dataFile."themes/catppuccin-mocha/openbox-3/themerc".text = ''
            # Catppuccin Mocha theme for labwc

            # Title bar
            window.active.title.bg: flat solid
            window.active.title.bg.color: #1e1e2e
            window.inactive.title.bg: flat solid
            window.inactive.title.bg.color: #181825

            # Title text
            window.active.label.bg: parentrelative
            window.active.label.text.color: #cdd6f4
            window.inactive.label.bg: parentrelative
            window.inactive.label.text.color: #6c7086

            # Borders
            border.width: 1
            window.active.border.color: #45475a
            window.inactive.border.color: #313244
            window.active.client.color: #45475a
            window.inactive.client.color: #313244

            # Buttons
            window.active.button.unpressed.bg: parentrelative
            window.active.button.unpressed.image.color: #cdd6f4
            window.active.button.hover.bg: parentrelative
            window.active.button.hover.image.color: #f5e0dc
            window.inactive.button.unpressed.bg: parentrelative
            window.inactive.button.unpressed.image.color: #6c7086

            # Close button
            window.active.button.close.hover.image.color: #f38ba8
            window.active.button.close.pressed.image.color: #eba0ac

            # Menu
            menu.items.bg: flat solid
            menu.items.bg.color: #1e1e2e
            menu.items.text.color: #cdd6f4
            menu.items.active.bg: flat solid
            menu.items.active.bg.color: #45475a
            menu.items.active.text.color: #cdd6f4
            menu.separator.color: #45475a

            # OSD
            osd.bg: flat solid
            osd.bg.color: #1e1e2e
            osd.label.text.color: #cdd6f4
          '';

          # GTK window buttons (left side) + dark theme
          dconf.settings = {

            "org/gnome/desktop/wm/preferences" = {
              button-layout = "close,minimize,maximize:appmenu";
            };
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-theme = "Adwaita-dark";
              gtk-decoration-layout = "close,minimize,maximize:menu";
            };
            "org/freedesktop/appearance" = {
              color-scheme = lib.hm.gvariant.mkUint32 1; # 1 = prefer-dark
            };
          };

          # GTK theme
          gtk = {
            enable = true;
            theme = {
              name = "Adwaita-dark";
              package = pkgs.gnome-themes-extra;
            };
            gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
            gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
          };

          # Qt theme
          qt = {
            enable = true;
            platformTheme.name = "qtct";
          };

          wayland.windowManager.labwc = {
            enable = true;

            rc = {
              theme = {
                name = "catppuccin-mocha";
                titlebar = {
                  layout = "close,iconify,max:";
                };
              };
              libinput = {
                device = [
                  {
                    "@category" = "default";
                    accelProfile = "flat";
                    pointerSpeed = "-0.25";
                  }
                ];
              };
              keyboard = {
                default = true;
                layoutScope = "global";
                xkb = {
                  layout = "pl";
                };
                keybind = [
                  {
                    "@key" = "Super_L";
                    "@onRelease" = "yes";
                    action = {
                      "@name" = "Execute";
                      "@command" = fuzzelToggle;
                    };
                  }
                  {
                    "@key" = "W-Return";
                    action = {
                      "@name" = "Execute";
                      "@command" = "ghostty";
                    };
                  }
                  {
                    "@key" = "W-d";
                    action = {
                      "@name" = "Execute";
                      "@command" = "fuzzel";
                    };
                  }
                  {
                    "@key" = "W-q";
                    action = {
                      "@name" = "Close";
                    };
                  }
                  {
                    "@key" = "W-f";
                    action = {
                      "@name" = "ToggleFullscreen";
                    };
                  }
                  {
                    "@key" = "A-F4";
                    action = {
                      "@name" = "Close";
                    };
                  }
                  {
                    "@key" = "A-Tab";
                    action = {
                      "@name" = "NextWindow";
                    };
                  }
                  {
                    "@key" = "A-S-Tab";
                    action = {
                      "@name" = "PreviousWindow";
                    };
                  }
                  # Lock screen
                  {
                    "@key" = "W-l";
                    action = {
                      "@name" = "Execute";
                      "@command" = "swaylock";
                    };
                  }
                  # Screenshots
                  {
                    "@key" = "W-S-s";
                    action = {
                      "@name" = "Execute";
                      "@command" = "sh -c 'grim -g \"$(slurp)\" - | wl-copy'";
                    };
                  }
                  {
                    "@key" = "C-W-S-s";
                    action = {
                      "@name" = "Execute";
                      "@command" = "sh -c 'grim - | wl-copy'";
                    };
                  }
                  # Display mode (Win+P)
                  {
                    "@key" = "W-p";
                    action = {
                      "@name" = "Execute";
                      "@command" = displayModeToggle;
                    };
                  }
                  # Volume controls
                  {
                    "@key" = "XF86AudioRaiseVolume";
                    action = {
                      "@name" = "Execute";
                      "@command" = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+";
                    };
                  }
                  {
                    "@key" = "XF86AudioLowerVolume";
                    action = {
                      "@name" = "Execute";
                      "@command" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
                    };
                  }
                  {
                    "@key" = "XF86AudioMute";
                    action = {
                      "@name" = "Execute";
                      "@command" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                    };
                  }
                  # Fine volume controls (Shift + volume keys = 1%)
                  {
                    "@key" = "S-XF86AudioRaiseVolume";
                    action = {
                      "@name" = "Execute";
                      "@command" = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+";
                    };
                  }
                  {
                    "@key" = "S-XF86AudioLowerVolume";
                    action = {
                      "@name" = "Execute";
                      "@command" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
                    };
                  }
                ];
              };
              mouse = {
                default = true;
                context = [
                  {
                    "@name" = "Root";
                    mousebind = [
                      {
                        "@button" = "Left";
                        "@action" = "Press";
                        action = {
                          "@name" = "None";
                        };
                      }
                      {
                        "@button" = "Right";
                        "@action" = "Press";
                        action = {
                          "@name" = "ShowMenu";
                          "@menu" = "root-menu";
                        };
                      }
                    ];
                  }
                ];
              };
            };

            menu = [
              {
                menuId = "root-menu";
                label = "";
                items = [
                  {
                    label = "Ghostty";
                    action = {
                      name = "Execute";
                      command = "ghostty";
                    };
                  }
                  {
                    label = "Fuzzel";
                    action = {
                      name = "Execute";
                      command = fuzzelToggle;
                    };
                  }
                  { separator = true; }
                  {
                    label = "Reconfigure";
                    action = {
                      name = "Reconfigure";
                    };
                  }
                  {
                    label = "Exit";
                    action = {
                      name = "Exit";
                    };
                  }
                ];
              }
            ];

            autostart = [
              "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_RUNTIME_DIR PATH XDG_DATA_DIRS"
              "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_RUNTIME_DIR PATH XDG_DATA_DIRS"
              "sh -c 'wlr-randr --output HDMI-A-2 --pos 0,0 --mode 3840x2160@240Hz --output HDMI-A-1 --pos 3840,0 && qs &'"
            ];
          };
        }
      )
    ];
  };
}
