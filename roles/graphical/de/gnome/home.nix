{
  lib,
  pkgs,
  inputs,
  ...
}:
with lib.hm.gvariant;
{
  programs.gnome-shell = {
    enable = true;
    extensions =
      (with pkgs.gnomeExtensions; [
        { package = appindicator; }
        { package = caffeine; }
        { package = media-progress; }
        # causes extremely low screenshots quality
        # https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/7903
        # https://github.com/flexagoon/rounded-window-corners/issues/36
        # https://gitlab.gnome.org/GNOME/mutter/-/issues/3346
        # { package = rounded-window-corners-reborn; }
        { package = window-is-ready-remover; }
        { package = search-light; }
        { package = blur-my-shell; }
        { package = start-overlay-in-application-view; }
        # { package = airpod-battery-monitor; } # doesn't work
        # development
        # {
        # package = inputs.dash-to-panel-win11.packages.${pkgs.system}.default.overrideAttrs (oldAttrs: {
        #   postInstall = ''
        #     ${oldAttrs.postInstall or ""}
        #     rm -rf $out/share/gnome-shell/extensions/dash-to-panel@makindotcc.github.com
        #     ln -s /home/user/Documents/dev/dash-to-panel/ $out/share/gnome-shell/extensions/dash-to-panel@makindotcc.github.com
        #     touch $out/share/gnome-shell/extensions/kurczeasf45.txt
        #   '';
        # });
        # }
      ])
      ++ [
        {
          package = inputs.dash-to-panel-win11.packages.${pkgs.system}.default;
        }
      ];
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-show-date = true;
      clock-show-seconds = true;
      clock-show-weekday = true;
      gtk-theme = "adw-gtk3-dark";

      font-name = "SFRounded Nerd Font 11";
      document-font-name = "SFRounded Nerd Font 11";
      monospace-font-name = "SFMono Nerd Font 10";
      font-antialiasing = "grayscale";
      font-hinting = "full";
    };
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
      mouse-button-modifier = "<Super>";
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "discord.desktop"
        "org.telegram.desktop.desktop"
        "firefox.desktop"
      ];
    };
    "org/gnome/shell/extensions/appindicator" = {
      icon-saturation = 1.0;
      legacy-tray-enabled = true;
    };
    "org/gnome/shell/extensions/dash-to-panel" = {
      animate-appicon-hover = false;
      appicon-margin = 0;
      appicon-padding = 8;
      appicon-style = "NORMAL";
      available-monitors = [ 0 ];
      click-action = "MINIMIZE";
      desktop-line-custom-color = "rgba(200,200,200,0.2)";
      desktop-line-use-custom-color = true;
      dot-color-1 = "#5294e2";
      dot-color-2 = "#5294e2";
      dot-color-3 = "#5294e2";
      dot-color-4 = "#5294e2";
      dot-color-dominant = false;
      dot-color-override = false;
      dot-color-unfocused-1 = "#5294e2";
      dot-color-unfocused-2 = "#5294e2";
      dot-color-unfocused-3 = "#5294e2";
      dot-color-unfocused-4 = "#5294e2";
      dot-color-unfocused-different = false;
      dot-position = "BOTTOM";
      dot-size = 0;
      dot-style-focused = "DOTS";
      dot-style-unfocused = "SEGMENTED";
      focus-highlight = true;
      focus-highlight-color = "#9a9996";
      focus-highlight-dominant = false;
      focus-highlight-opacity = 25;
      group-apps = false;
      group-apps-label-font-color = "#ffffff";
      group-apps-label-font-size = 12;
      group-apps-label-font-weight = "normal";
      group-apps-label-max-width = 110;
      group-apps-underline-unfocused = false;
      group-apps-use-fixed-width = false;
      group-apps-use-launchers = false;
      hot-keys = true;
      hotkeys-overlay-combo = "TEMPORARILY";
      intellihide = false;
      isolate-monitors = false;
      isolate-workspaces = false;
      leftbox-padding = -1;
      leftbox-size = 0;
      middle-click-action = "LAUNCH";
      multi-monitors = false;
      panel-anchors = ''
        {"0":"MIDDLE","1":"MIDDLE"}
      '';
      panel-element-positions = ''
        {"0":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"centered"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],"1":[{"element":"showAppsButton","visible":true,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}
      '';
      panel-element-positions-monitors-sync = true;
      panel-lengths = ''
        {"0":100,"1":100}
      '';
      panel-positions = ''
        {"0":"BOTTOM"}
      '';
      panel-sizes = ''
        {"0":40,"1":44}
      '';
      preview-custom-opacity = 80;
      preview-use-custom-opacity = true;
      primary-monitor = 0;
      progress-show-count = true;
      shift-click-action = "MINIMIZE";
      shift-middle-click-action = "LAUNCH";
      show-appmenu = false;
      show-apps-icon-file = "";
      show-apps-icon-side-padding = 8;
      show-running-apps = true;
      show-showdesktop-delay = 300;
      show-showdesktop-hover = true;
      show-showdesktop-time = 200;
      showdesktop-button-width = 1;
      status-icon-padding = -1;
      stockgs-keep-dash = false;
      stockgs-keep-top-panel = false;
      stockgs-panelbtn-click-only = false;
      trans-bg-color = "#1a161f";
      trans-dynamic-anim-target = 1.0;
      trans-dynamic-distance = 10;
      trans-gradient-top-color = "#77767b";
      trans-gradient-top-opacity = 0.15;
      trans-panel-opacity = 0.0;
      trans-use-custom-bg = false;
      trans-use-custom-gradient = false;
      trans-use-custom-opacity = true;
      trans-use-dynamic-opacity = false;
      tray-padding = 4;
      tray-size = 0;
      window-preview-title-position = "TOP";
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      settings-version = 2;
    };
    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = 1.0;
    };
    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blacklist = [
        "Plank"
        "com.desktop.ding"
        "Conky"
        "firefox"
        "google-chrome"
      ];
      blur = true;
      enable-all = false;
      opacity = 250;
      whitelist = [
        "org.gnome.Extensions"
        "org.gnome.Extensions"
        "org.gnome.Settings"
        "org.gnome.Console"
      ];
    };
    "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      pipeline = "pipeline_default_rounded";
    };
    "org/gnome/shell/extensions/blur-my-shell/dash-to-panel" = {
      blur-original-panel = true;
    };
    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
      brightness = 0.9;
      force-light-text = false;
      override-background = false;
      override-background-dynamically = true;
      pipeline = "pipeline_default";
      sigma = 90;
      static-blur = false;
      style-panel = 0;
      unblur-in-overview = true;
    };
    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ "<Super>k" ]; # rebind default <Super>space to search-light

      switch-applications = [ ];
      switch-applications-backward = [ ];
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "<Control><Super>s" ];
      screenshot-window = [ "<Shift><Control><Super>s" ];
    };

    "org/gnome/shell/extensions/search-light" = {
      background-color = mkTuple [
        0.0
        0.0
        0.0
        0.78333336114883423
      ];
      blur-background = true;
      blur-brightness = 0.6;
      blur-sigma = 30.0;
      border-color = mkTuple [
        1.0
        1.0
        1.0
        1.0
      ];
      border-radius = 2.3800000000000003;
      currency-converter = false;
      entry-font-size = 1;
      monitor-count = 2;
      popup-at-cursor-monitor = true;
      preferred-monitor = 0;
      scale-height = 0.2;
      scale-width = 0.1;
      shortcut-search = [ "<Super>space" ];
      show-panel-icon = false;
      window-effect = 0;
      window-effect-color = mkTuple [
        1.0
        1.0
        1.0
        1.0
      ];
    };

    # not working, needs fix.
    # "org/gnome/shell/extensions/Airpod-Battery-Monitor" = {
    #   gui-interface = true;
    # };
  };
}
