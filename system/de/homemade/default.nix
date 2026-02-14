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
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config.common.default = "*";
    };

    environment.systemPackages = with pkgs; [
      labwc
      swaybg
      fuzzel
      wlr-randr
      grim
      slurp
      wl-clipboard
    ];

    services.displayManager.sessionPackages = [ pkgs.labwc ];

    programs.dconf.enable = true;

    # impermanence

    home-manager.sharedModules = [
      (
        { config, ... }:
        let
          fuzzelToggle = "sh -c 'qs ipc --pid $(pgrep -f bin/quickshell | head -1) call fuzzel toggle'";
        in
        {
          programs.quickshell = {
            enable = true;
            # configs.default = ./shell;
          };

          xdg.configFile."quickshell/shell.qml".source =
            config.lib.file.mkOutOfStoreSymlink "/home/user/.config/nix/system/de/homemade/shell/shell.qml";

          # GTK window buttons (left side) + dark theme
          dconf.settings = {
            "org/gnome/desktop/wm/preferences" = {
              button-layout = "close,minimize,maximize:appmenu";
            };
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              gtk-theme = "Adwaita-dark";
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
            platformTheme.name = "adwaita";
            style = {
              name = "adwaita-dark";
              package = pkgs.adwaita-qt;
            };
          };

          wayland.windowManager.labwc = {
            enable = true;

            rc = {
              theme = {
                titlebar = {
                  layout = "close,iconify,maximize:";
                };
              };
              libinput = {
                device = [
                  {
                    "@category" = "default";
                    accelProfile = "flat";
                    pointerSpeed = "-0.2";
                  }
                ];
              };
              keyboard = {
                default = true;
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
                ];
              };
              mouse = {
                default = true;
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
              "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
              "sh -c 'wlr-randr --output HDMI-A-2 --pos 0,0 --mode 3840x2160@240Hz --output HDMI-A-1 --pos 3840,0; swaybg -i ${../wallpaper.png} & qs &'"
            ];
          };
        }
      )
    ];
  };
}
