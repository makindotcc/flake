{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./programs
    ./hardware
  ];

  options.de.homemade.enable = lib.mkEnableOption "Enable homemade desktop environment." // {
    default = config.de.type == "homemade";
  };

  config = lib.mkIf config.de.homemade.enable (
    let
      uid =
        let
          u = config.users.users.user.uid;
        in
        if u == null then throw "users.users.user.uid must be set explicitly" else toString u;
      monitorSetup = "${pkgs.wlr-randr}/bin/wlr-randr --output HDMI-A-1 --pos 0,0 --mode 3840x2160@240Hz --on --output HDMI-A-2 --pos 3840,0 --on";
      pixdecor = pkgs.stdenv.mkDerivation {
        pname = "pixdecor";
        version = "0-unstable-2026-02-13";
        src = pkgs.fetchFromGitHub {
          owner = "soreau";
          repo = "pixdecor";
          rev = "4893c7362d1b9b90b1208504579bc5b9618eceb5";
          hash = "sha256-+NvnG8tYc0M5zdxaI375+gqeWWWePyqPp+njI07ooXM=";
        };
        nativeBuildInputs = with pkgs; [
          meson
          ninja
          pkg-config
          wayland-scanner
        ];
        buildInputs = with pkgs; [
          wayfire
          glm
          libGL
          libxkbcommon
          libdrm
          libinput
          libevdev
          vulkan-headers
          libxcb-wm
          gtkmm3
        ];
        env.PKG_CONFIG_WAYFIRE_METADATADIR = "${placeholder "out"}/share/wayfire/metadata";
      };
    in
    {
      nixpkgs.overlays = [
        (final: prev: {
          wayfire = prev.wayfire.overrideAttrs (old: {
            version = "0-unstable-2026-02-21";
            src = inputs.wayfire-src;
            mesonFlags = (builtins.filter (f: f != "-Duse_system_wfconfig=enabled") old.mesonFlags) ++ [
              "-Duse_system_wfconfig=disabled"
            ];
          });
        })
      ];

      programs.wayfire = {
        enable = true;
        plugins = [
          (pkgs.wayfirePlugins.wayfire-plugins-extra.override { withPixdecorPlugin = false; })
          pixdecor
        ];
      };

      programs.uwsm = {
        enable = true;
        waylandCompositors.wayfire = {
          prettyName = "Wayfire";
          comment = "Wayfire compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/wayfire";
        };
      };

      xdg.portal = {
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        wlr.settings.screencast = {
          chooser_type = "dmenu";
          chooser_cmd = "${pkgs.fuzzel}/bin/fuzzel -d";
        };
        config = {
          wayfire = {
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
        wayfirePlugins.wcm
        gsettings-desktop-schemas
        glib
        qt6Packages.qt6ct
        libsForQt5.qt5ct
        wlr-randr
        wlopm
        grim
        slurp
        wl-clipboard
        blueman
        loupe
      ];

      services.gnome.gnome-keyring.enable = true;

      security.pam.services.swaylock = { };
      security.pam.services.sddm.enableGnomeKeyring = true;
      security.polkit.enable = true;

      services.graphical-desktop.enable = true;

      programs.dconf.enable = true;

      environment.sessionVariables = {
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_CACHE_HOME = "$HOME/.cache";
        QT_QPA_PLATFORMTHEME = "qt6ct";
        QT_STYLE_OVERRIDE = "Fusion";
        GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
        WAYFIRE_PLUGIN_XML_PATH = "${pkgs.wayfire}/share/wayfire/metadata:${pixdecor}/share/wayfire/metadata";
        OBS_USE_EGL = "1";
      };

      systemd.services.quickshell-freeze = {
        description = "Freeze quickshell before suspend to prevent issues with missing components on primary screen";
        before = [
          "sleep.target"
          "hibernate.target"
          "hybrid-sleep.target"
        ];
        wantedBy = [
          "sleep.target"
          "hibernate.target"
          "hybrid-sleep.target"
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "user";
          Environment = "XDG_RUNTIME_DIR=/run/user/${uid}";
          ExecStart = "systemctl --user freeze quickshell";
        };
      };

      # ja pierdole
      systemd.services.quickshell-thaw = {
        description = "Thaw quickshell after resume";
        after = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "systemd-hybrid-sleep.service"
        ];
        wantedBy = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "user";
          Environment = "XDG_RUNTIME_DIR=/run/user/${uid}";
          ExecStart = toString (
            pkgs.writeShellScript "quickshell-thaw" ''
              # wait until all outputs are available in full resolution
              # for some reason for primary screen it takes some time for 240hz mode to become available after resume
              # i think this is due to DSC?
              elapsed=0
              while [ $elapsed -lt 100 ]; do
                outputs=$($wlr_randr 2>&1) || true
                if echo "$outputs" | grep -q "HDMI-A-1" \
                  && echo "$outputs" | grep -q "HDMI-A-2" \
                  && echo "$outputs" | grep -q "3840x2160 px, 240.000000 Hz"; then
                  break
                fi
                sleep 0.1
                elapsed=$((elapsed + 1))
              done

              ${monitorSetup}
              systemctl --user thaw quickshell
            ''
          );
        };
      };

      home-manager.sharedModules = [
        (
          {
            config,
            pkgs,
            lib,
            ...
          }:
          let
            launcherToggle = "sh -c 'qs ipc --pid $(pgrep -f bin/quickshell | head -1) call launcher toggle'";
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

            services.swayidle = {
              enable = true;
              timeouts =
                let
                  screenTimeout = 600;
                in
                [
                  {
                    timeout = screenTimeout - 15;
                    command = "${pkgs.libnotify}/bin/notify-send 'Locking in 15 seconds' -t 15000";
                  }
                  {
                    timeout = screenTimeout;
                    command = "${pkgs.swaylock}/bin/swaylock -f";
                  }
                  {
                    timeout = 900;
                    command = "${pkgs.wlopm}/bin/wlopm --off '*'";
                    resumeCommand = "${pkgs.wlopm}/bin/wlopm --on '*'";
                  }
                ];
              events = {
                before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
                after-resume = "${pkgs.wlopm}/bin/wlopm --on '*'";
              };
            };

            programs.quickshell = {
              enable = true;
              package = pkgs.quickshell;
              # configs.default = ./shell;
            };

            systemd.user.services.quickshell = {
              Unit = {
                Description = "Quickshell";
                After = [ "graphical-session.target" ];
                PartOf = [ "graphical-session.target" ];
              };
              Service = {
                ExecStart = "${pkgs.quickshell}/bin/qs";
                Restart = "on-failure";
                RestartSec = 2;
              };
              Install.WantedBy = [ "graphical-session.target" ];
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

            # GTK window buttons (left side) + dark theme
            dconf.settings = {

              "org/gnome/desktop/wm/preferences" = {
                button-layout = "close,minimize,maximize:";
              };
              "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
                gtk-theme = "Adwaita-dark";
                gtk-decoration-layout = "close,minimize,maximize:";
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

            xdg.configFile."wayfire.ini".text = ''
              [core]
              plugins = animate autostart command pixdecor foreign-toplevel fast-switcher move place resize vswitch wm-actions workarounds session-lock

              [input]
              xkb_layout = pl
              mouse_accel_profile = flat
              mouse_cursor_speed = -0.45

              [output:HDMI-A-1]
              mode = 3840x2160@240000
              position = 0,0

              [output:HDMI-A-2]
              mode = auto
              position = 3840,0

              [pixdecor]
              border_size = 0
              titlebar = always
              button_layout = close,minimize,maximize:
              fg_color = 0.118 0.118 0.180 1.0
              bg_color = 0.094 0.094 0.145 1.0
              fg_text_color = 0.804 0.839 0.957 1.0
              bg_text_color = 0.424 0.439 0.525 1.0
              title_font = sans 12
              title_text_align = 1
              overlay_engine = rounded_corners
              rounded_corner_radius = 6
              shadow_radius = 20
              shadow_color = 0.0 0.0 0.0 0.333
              button_color = 0.804 0.839 0.957 1.0
              left_button_x_offset = 6

              [animate]
              minimize_animation = zoom
              zoom_duration = 300ms circle

              [autostart]
              uwsm = uwsm finalize

              [command]
              binding_terminal = <super> KEY_ENTER
              command_terminal = ghostty

              # release_binding_launcher = <super>
              # command_launcher = ${launcherToggle}

              binding_launcher2 = <super> KEY_SPACE
              command_launcher2 = ${launcherToggle}

              binding_lock = <super> KEY_L
              command_lock = swaylock

              binding_screenshot = <super> <shift> KEY_S
              command_screenshot = sh -c 'grim -g "$(slurp)" - | wl-copy'

              binding_screenshot_full = <ctrl> <super> <shift> KEY_S
              command_screenshot_full = sh -c 'grim - | wl-copy'

              binding_display_mode = <super> KEY_P
              command_display_mode = ${displayModeToggle}

              binding_vol_up = KEY_VOLUMEUP
              command_vol_up = wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+

              binding_vol_down = KEY_VOLUMEDOWN
              command_vol_down = wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-

              binding_vol_mute = KEY_MUTE
              command_vol_mute = wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

              binding_vol_up_fine = <shift> KEY_VOLUMEUP
              command_vol_up_fine = wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 1%+

              binding_vol_down_fine = <shift> KEY_VOLUMEDOWN
              command_vol_down_fine = wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-

              [move]
              activate = <super> BTN_LEFT

              [resize]
              activate = <super> BTN_RIGHT

              [wm-actions]
              toggle_fullscreen = <super> KEY_F
              close = <super> KEY_Q

              [fast-switcher]
              activate = <alt> KEY_TAB
              activate_backward = <alt> <shift> KEY_TAB
            '';
          }
        )
      ];
    }
  );
}
