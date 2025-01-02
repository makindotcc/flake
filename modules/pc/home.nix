{ pkgs, inputs, ... }:
{
  home.file.".mozilla/firefox/nix-user-profile/chrome/firefox-gnome-theme".source =
    inputs.firefox-gnome-theme;

  programs = {
    # idk, i'll use github sync ig?
    # vscode = {
    #   enable = true;
    #   extensions = with pkgs; [
    #     vscode-extensions.jnoortheen.nix-ide
    #     vscode-extensions.k--kato.intellij-idea-keybindings
    #     vscode-extensions.github.copilot
    #   ];
    #   userSettings = builtins.fromJSON (builtins.readFile ./config/vscode-userSettings.json);
    # };
    nushell = {
      shellAliases = {
        nixcfg = "code ~/.config/nix";
      };
    };
    firefox = {
      enable = true;
      profiles.default = {
        userChrome = ''
          @import "${inputs.firefox-gnome-theme}/userChrome.css";
        '';
        userContent = ''
          @import "${inputs.firefox-gnome-theme}/userContent.css";
        '';
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.uidensity" = 0;
          "svg.context-properties.content.enabled" = true;
          "browser.theme.dark-private-windows" = false;
        };
      };
    };
  };

  programs.gnome-shell = {
    enable = true;
    extensions = with pkgs.gnomeExtensions; [
      { package = appindicator; }
      { package = caffeine; }
      { package = media-progress; }
      { package = rounded-window-corners-reborn; }
      { package = window-is-ready-remover; }
      { package = blur-my-shell; }
      {
        package = dash-to-panel.overrideAttrs (oldAttrs: {
          postInstall = ''
            ${oldAttrs.postInstall or ""}
            rm -rf $out/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com
            ln -s /home/user/Documents/dev/dash-to-panel/ $out/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com
            touch $out/share/gnome-shell/extensions/kurczeasf4.txt
          '';
        });
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
        {"0":40,"1":48}
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
  };
}
